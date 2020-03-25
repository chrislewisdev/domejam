import "graphics" for Canvas, Color
import "math" for Math, Point
import "./src/controls" for KeyMapping, Action, Controls
import "./src/matchSearcher" for MatchSearcher
import "./src/constants" for Constants
import "./src/gfx" for Gfx
import "./src/sfx" for Sfx
import "./src/block" for Block
import "./src/mathUtils" for MathUtils

var MATCH_ANIMATION_TARGET = Point.new(0, 0)

class PlayScreen {
  construct new(state, gameInstance) {
    _state = state
    _gameInstance = gameInstance

    // Some basic state for the player controls. 'x' for moving the cursor, 'tile' for which tile to place
    _x = 5
    _tile = 0
    _isPlacingBlock = false

    // For a description of the controls model check controls.wren
    _controls = Controls.new().
      withAction(Action.new(Fn.new{ moveLeft() }).
        withMapping(KeyMapping.new("Left"))).
      withAction(Action.new(Fn.new{ moveRight() }).
        withMapping(KeyMapping.new("Right"))).
      withAction(Action.new(Fn.new{ placeBlock() }, 50).
        withMapping(KeyMapping.new("Down"))).
      withAction(Action.new(Fn.new{ cycleTile() }).
        withMapping(KeyMapping.new("Z"))).
      withAction(Action.new(Fn.new{ resetLevel() }).
        withMapping(KeyMapping.new("X")))

    // Used to iterate through values used for graphics effects
    _dashOffsetCycler = MathUtils.getCycler(0, 12, 1, 0.5)
    _ghostCycler = MathUtils.getCycler(0, 4, 5, 1)

    // Used for holding the animated blocks that move off-screen when you make a match
    // They no longer exist on the game's map object so need to store them somewhere :)
    _animatedBlocks = []

    // Used to track any Wren fibers that are currently running. We call these every frame to enable 
    // actions that take place over multiple frames.
    _fibers = []
  }

  moveLeft() {
    if (_x > 0) _x = _x - 1
    Sfx.playMovementSound()
  }

  moveRight() {
    if (_x < Constants.mapWidth - 1) _x = _x + 1
    Sfx.playMovementSound()
  }

  placeBlock() {
    var target = getDropTarget()

    if (target.y < 0 || _isPlacingBlock) return

    // The actual block placement needs to happen in a fiber so that we can space the steps out over several seconds
    _fibers.add(Fiber.new {
      // Setting this to true will prevent the player from placing more blocks while this is resolving
      _isPlacingBlock = true

      // Update the game state
      _state.tileAllowances[_tile] = _state.tileAllowances[_tile] - 1
      _state.setTile(target.x, target.y, _tile)
      
      Sfx.playBlockDropSound()

      // Repeatedly check for matches until no more are found
      while (checkForAllMatches()) {
        Sfx.playMatchSound()
        waitForFrames(30)
        shiftCellsDown()
        waitForFrames(30)
      }

      // Check for win/lose states
      if (_state.isLevelClear()) {
        waitForFrames(60)
        _gameInstance.startNextLevel()
      } else if (_state.isLevelFailed()) {
        waitForFrames(60)
        _gameInstance.levelFailed()
      }

      enforceAllowances()

      _isPlacingBlock = false
    })
  }

  // Iterates through all cells on the grid and checks for a match starting there.
  // This is necessary because falling blocks could create new matches after the player places a tile.
  checkForAllMatches() {
    for (cell in _state.allCells) {
      if (checkForMatch(cell)) {
        return true
      }
    }

    return false
  }

  // Cycles the currently selected tile between all available options
  cycleTile() {
    _tile = _tile + 1
    if (_tile > 2) _tile = 0
    enforceAllowances()
  }

  resetLevel() {
    _state.loadLevel(_state.currentLevel)
  }

  // Continues to yield back control of a fiber until it has been called the specified amount of times.
  // So you can delay your fiber for a certain number of frames
  waitForFrames(frames) {
    var waited = 0
    while (waited < frames) {
      waited = waited + 1
      Fiber.yield()
    }
  }

  // Makes sure that the player's current tile selection is one that they actually have tiles left to place.
  enforceAllowances() {
    while (_state.tileAllowances[_tile] == 0 && _state.tileAllowances.any{|allowance| allowance != 0}) {
      cycleTile()
    }
  }

  // Initiates a search for matches on the given cell co-ordinates
  // Ignores calls that are empty or have solid blocks in them
  // Returns true if a match was found
  checkForMatch(cell) {
    var tile = _state.getTile(cell.x, cell.y)

    if (tile == null || tile == 9) return false

    var matches = MatchSearcher.new(_state.map, cell).search()
    if (matches.count >= 3) {
      animateBlocks(matches.map{|match| Block.new(tile, MathUtils.cellsToPixels(match))})
      for (c in matches) {
        _state.setTile(c.x, c.y, null)
      }
      return true
    }

    return false
  }

  // Looks for tiles that have an empty space below them, and shifts them down by one
  // Intended to be called after any match has been made
  shiftCellsDown() {
    for (y in (Constants.mapHeight - 1)..1) {
      for (x in 0...Constants.mapWidth) {
        if (_state.getTile(x, y) == null && _state.getTile(x, y - 1) != null && _state.getTile(x, y - 1) != 9) {
          _state.setTile(x, y, _state.getTile(x, y - 1))
          _state.setTile(x, y - 1, null)
        }
      }
    }
  }

  // Adds a list of blocks to those that need to be drawn/animated after a match is made
  animateBlocks(blocks) {
    _animatedBlocks = _animatedBlocks + blocks
  }

  update() {
    _controls.evaluate()
    enforceAllowances()

    // Call all current fibers, and then remove any that have completed
    _fibers.each{|fiber| fiber.call()}
    _fibers = _fibers.where{|fiber| !fiber.isDone}.toList

    // For all matched blocks that need animating, move them towards the corner of the screen
    // When they reach there, remove them
    for (block in _animatedBlocks) {
      block.point = MathUtils.moveTowards(block.point, MATCH_ANIMATION_TARGET, 6)
    }
    if (_animatedBlocks.any{|block| block.point == MATCH_ANIMATION_TARGET}) Sfx.playBlockDisappearSound()
    _animatedBlocks = _animatedBlocks.where{|block| block.point != MATCH_ANIMATION_TARGET}.toList
  }

  // Based on the current cursor position, works out where the player's dropped tile should end up
  // Returns that as a Point object
  getDropTarget() {
    var y = -1
    while (y < Constants.mapHeight - 1) {
      if (_state.getTile(_x, y + 1) != null) break
      y = y + 1
    }
    return Point.new(_x, y)
  }

  draw(dt) {
    Gfx.drawMap(_state.map)

    // Only draw the player's cursor if we're not already handling a dropped tile
    if (!_isPlacingBlock) {
      Gfx.drawCursor(_tile, _x)

      var dropTarget = MathUtils.cellsToPixels(getDropTarget())
      var linex = _x * Constants.tileSize + Constants.tileSize / 2

      Gfx.drawDashedLine(linex, Constants.tileSize, linex, dropTarget.y + Constants.tileSize / 2, _dashOffsetCycler.call())
      Gfx.drawGhostTile(_tile, dropTarget.x, dropTarget.y, _ghostCycler.call())

      Canvas.print("%(_state.tileAllowances[_tile]) left", linex + 12, dropTarget.y / 2, Color.white)
    }

    for (block in _animatedBlocks) {
      Gfx.drawTile(block.tile, block.point.x, block.point.y)
    }

    // Draw the HUD on the side of the screen
    Canvas.print("<-/->: move", 295, 10, Color.white)
    Canvas.print("down: drop", 295, 25, Color.white)
    Canvas.print("z: next tile", 295, 40, Color.white)
    Canvas.print("x: reset", 295, 55, Color.white)

    Gfx.drawTile(0, 310, 100)
    Canvas.print("x %(_state.tileAllowances[0])", 346, 108, Color.white)
    Gfx.drawTile(1, 310, 150)
    Canvas.print("x %(_state.tileAllowances[1])", 346, 158, Color.white)
    Gfx.drawTile(2, 310, 200)
    Canvas.print("x %(_state.tileAllowances[2])", 346, 208, Color.white)

    // Draw a box around the currently selected tile
    Canvas.rect(300, 90 + _tile * 50, 85, 44, Color.white)
  }
}
