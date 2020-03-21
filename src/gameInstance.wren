import "dome" for Process
import "graphics" for Canvas, Color
import "math" for Math, Point
import "./src/controls" for KeyMapping, Action, Controls
import "./src/matchSearcher" for MatchSearcher
import "./src/constants" for Constants
import "./src/gfx" for Gfx
import "./src/sfx" for Sfx

var MATCH_ANIMATION_TARGET = Point.new(360, 0)

var LEVELS = [
["
s_s
xxx
", 1, 0, 0],
["
s_s
b_b
d_d
", 1, 1, 1],
["
s_b
b_s
d_d
", 1, 1, 2],
["
d___d
xb_bx
xsbsx
xxxxx
", 4, 3, 1],
]

class Block {
  tile { _tile }
  point { _point }
  point=(value) { _point = value }
  
  construct new(tile, point) {
    _tile = tile
    _point = point
  }
}

class GameState {
  map { _map }
  currentLevel { _currentLevel }
  tileAllowances { _tileAllowances }

  getTile(x, y) { _map[y][x] }
  setTile(x, y, tile) { _map[y][x] = tile}
  
  construct new() {
    _currentLevel = -1
  }

  loadLevel(level) {
    _map = List.filled(Constants.mapHeight, null)
    for (y in 0...Constants.mapHeight) {
      _map[y] = List.filled(Constants.mapWidth, null)
    }

    _currentLevel = level

    var levelString = LEVELS[level][0].trim()
    _tileAllowances = List.filled(3, 0)
    _tileAllowances[0] = LEVELS[level][1]
    _tileAllowances[1] = LEVELS[level][2]
    _tileAllowances[2] = LEVELS[level][3]

    var levelWidth = levelString.indexOf("\n") + 1
    if (levelWidth == 0) levelWidth = levelString.count
    var levelHeight = levelString.split("\n").count

    var xStart = Math.floor(Constants.mapWidth / 2) - Math.ceil(levelWidth / 2)
    var yStart = Constants.mapHeight - levelHeight

    var x = xStart
    var y = yStart

    for (char in levelString) {
      if (char == "_") {
        x = x + 1
      } else if (char == "\n") {
        x = xStart
        y = y + 1
      } else if (char == "s") {
        _map[y][x] = 0
        x = x + 1
      } else if (char == "d") {
        _map[y][x] = 1
        x = x + 1
      } else if (char == "b") {
        _map[y][x] = 2
        x = x + 1
      } else if (char == "x") {
        _map[y][x] = 9
        x = x + 1
      }
    }
  }

  isLevelClear() {
    for (y in 0...Constants.mapHeight) {
      for (x in 0...Constants.mapWidth) {
        if (_map[y][x] != null && _map[y][x] != 9) return false
      }
    }
    return true
  }

  allCells {
    return (0...Constants.mapHeight).map{|y| (0...Constants.mapWidth).map{|x| Point.new(x, y) }.toList}.reduce{|acc, row| acc + row.toList }
  }
}

class GameInstance {
  construct new() {
    __instance = this
    _state = GameState.new()
    _play = PlayMode.new(_state)
    startNextLevel()
  }

  static startNextLevel() {
    __instance.startNextLevel()
  }

  startNextLevel() {
    if (_state.currentLevel < LEVELS.count - 1) {
      _mode = LevelStartMode.new(_state)
    } else {
      youWin()
    }
  }

  static play() {
    __instance.play()
  }

  play() {
    _mode = _play
  }

  static levelFailed() {
    __instance.levelFailed()
  }

  levelFailed() {
    _mode = LevelFailedMode.new(_state)
  }

  static youWin() {
    __instance.youWin()
  }

  youWin() {
    _mode = GameFinishedMode.new()
  }

  update() {
    _mode.update()
  }

  draw(dt) {
    // if (_state.currentLevel >= 0) _play.draw(dt)
    _mode.draw(dt)
  }
}

class LevelStartMode {
  construct new(state) {
    _state = state
    _timer = 100
  }

  update() {
    _timer = _timer - 1

    if (_timer <= 0) {
      _state.loadLevel(_state.currentLevel + 1)
      GameInstance.play()
    }
  }

  draw(dt) {
    Canvas.rectfill(50, 100, 100, 20, Color.black)
    Canvas.rect(50, 100, 100, 20, Color.white)
    Canvas.print("Level %(_state.currentLevel + 2) / %(LEVELS.count)", 56, 106, Color.white)
    Gfx.scale2x(50, 100, 150, 120)
  }
}

class LevelFailedMode {
  construct new(state) {
    _state = state
    _timer = 100
  }

  update() {
    _timer = _timer - 1

    if (_timer <= 0) {
      _state.loadLevel(_state.currentLevel)
      GameInstance.play()
    }
  }

  draw(dt) {
    Canvas.rectfill(40, 100, 115, 36, Color.black)
    Canvas.rect(40, 100, 115, 36, Color.white)
    Canvas.print("Out of moves!", 46, 106, Color.white)
    Canvas.print("Try again", 61, 120, Color.white)
    Gfx.scale2x(40, 100, 160, 136)
  }
}

class GameFinishedMode {
  construct new() {}

  update() {}

  draw(dt) {
    Canvas.rectfill(35, 85, 115, 36, Color.black)
    Canvas.rect(35, 85, 115, 36, Color.white)
    Canvas.print("Congrats!", 57, 91, Color.white)
    Canvas.print("You win!", 60, 105, Color.white)
    Gfx.scale2x(35, 85, 155, 121)
  }
}

class PlayMode {
  construct new(state) {
    _state = state

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
      GameInstance.startNextLevel()
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
      GameInstance.levelFailed()
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
