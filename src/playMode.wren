import "graphics" for Canvas, Color
import "math" for Math, Point
import "./src/controls" for KeyMapping, Action, Controls
import "./src/matchSearcher" for MatchSearcher
import "./src/constants" for Constants
import "./src/gfx" for Gfx
import "./src/sfx" for Sfx
import "./src/block" for Block

var MATCH_ANIMATION_TARGET = Point.new(360, 0)

class PlayMode {
  construct new(state, gameInstance) {
    _state = state
    _gameInstance = gameInstance

    _x = 5

    _controls = Controls.new().
      withAction(Action.new(Fn.new{ moveLeft() }).
        withMapping(KeyMapping.new("Left"))).
      withAction(Action.new(Fn.new{ moveRight() }).
        withMapping(KeyMapping.new("Right"))).
      withAction(Action.new(Fn.new{ placeBlock() }, 50).
        withMapping(KeyMapping.new("Down"))).
      withAction(Action.new(Fn.new{ cycleTile() }).
        withMapping(KeyMapping.new("Z")))

    _dashOffset = 0

    _animatedBlocks = []

    _tile = 0
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
    if (target.y >= 0) _state.setTile(target.x, target.y, _tile)
    
    checkForAllMatches()

    _state.tileAllowances[_tile] = _state.tileAllowances[_tile] - 1

    if (_state.isLevelClear()) {
      _gameInstance.startNextLevel()
    } else {
      enforceAllowances()
    }

    Sfx.playBlockDropSound()
  }

  cycleTile() {
    _tile = _tile + 1
    if (_tile > 2) _tile = 0
    enforceAllowances()
  }

  enforceAllowances() {
    if (_state.tileAllowances.all{|allowance| allowance == 0}) {
      _gameInstance.levelFailed()
      return
    }

    while (_state.tileAllowances[_tile] == 0) {
      cycleTile()
    }
  }

  checkForAllMatches() {
    var repeat = false

    for (cell in _state.allCells) {
      if (checkForMatch(cell)) {
        Sfx.playMatchSound()
        shiftCellsDown()
        repeat = true
        break
      }
    }

    if (repeat) checkForAllMatches()
  }

  checkForMatch(cell) {
    var tile = _state.getTile(cell.x, cell.y)
    var countMatches = 1

    if (tile == null || tile == 9) return false

    var matches = MatchSearcher.new(_state.map, cell).search()
    if (matches.count >= 3) {
      animateBlocks(matches.map{|match| Block.new(tile, cellsToPixels(match))})
      for (c in matches) {
        _state.setTile(c.x, c.y, null)
      }
      return true
    }

    return false
  }

  shiftCellsDown() {
    for (y in (Constants.mapHeight - 1)..1) {
      for (x in 0...Constants.mapWidth) {
        if (_state.getTile(x, y) == null && _state.getTile(x, y - 1) != null) {
          _state.setTile(x, y, _state.getTile(x, y - 1))
          _state.setTile(x, y - 1, null)
        }
      }
    }
  }

  animateBlocks(blocks) {
    _animatedBlocks = _animatedBlocks + blocks
  }

  update() {
    _controls.evaluate()

    _dashOffset = _dashOffset + 0.5
    if (_dashOffset > 12) _dashOffset = 0

    for (block in _animatedBlocks) {
      block.point = moveTowards(block.point, MATCH_ANIMATION_TARGET, 6)
    }
    if (_animatedBlocks.any{|block| block.point == MATCH_ANIMATION_TARGET}) Sfx.playBlockDisappearSound()
    _animatedBlocks = _animatedBlocks.where{|block| block.point != MATCH_ANIMATION_TARGET}.toList
  }

  moveTowards(origin, destination, stepLength) {
    if ((destination - origin).length <= stepLength) return destination

    return origin + (destination - origin).unit * stepLength
  }

  getDropTarget() {
    var y = -1
    while (y < Constants.mapHeight - 1) {
      if (_state.getTile(_x, y + 1) != null) break
      y = y + 1
    }
    return Point.new(_x, y)
  }

  cellsToPixels(v) {
    return Point.new(v.x * Constants.tileSize, (v.y + 1) * Constants.tileSize)
  }

  draw(dt) {
    Gfx.drawMap(_state.map)
    Gfx.drawCursor(_tile, _x)

    var dropTarget = cellsToPixels(getDropTarget())
    var linex = _x * Constants.tileSize + Constants.tileSize / 2
    Gfx.drawDashedLine(linex, Constants.tileSize, linex, dropTarget.y + Constants.tileSize / 2, _dashOffset)
    Gfx.drawGhostTile(_tile, dropTarget.x, dropTarget.y)

    for (block in _animatedBlocks) {
      Gfx.drawTile(block.tile, block.point.x, block.point.y)
    }

    Gfx.drawTile(0, 310, 80)
    Canvas.print("x %(_state.tileAllowances[0])", 346, 88, Color.white)
    Gfx.drawTile(1, 310, 130)
    Canvas.print("x %(_state.tileAllowances[1])", 346, 138, Color.white)
    Gfx.drawTile(2, 310, 180)
    Canvas.print("x %(_state.tileAllowances[2])", 346, 188, Color.white)

    Canvas.rect(300, 70 + _tile * 50, 85, 44, Color.white)
  }
}
