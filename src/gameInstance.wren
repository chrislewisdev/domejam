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
d___d
xb_bx
xsbsx
xxxxx
", 4, 3, 1],
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

class GameInstance {
  construct new() {
    _tileAllowances = [0, 0, 0]
    loadLevel(0)

    _x = 5
    _moveCooldown = 0

    _controls = Controls.new().
      withAction(Action.new(Fn.new{ moveLeft() }).
        withMapping(KeyMapping.new("Left"))).
      withAction(Action.new(Fn.new{ moveRight() }).
        withMapping(KeyMapping.new("Right"))).
      withAction(Action.new(Fn.new{ placeBlock() }, 50).
        withMapping(KeyMapping.new("Down"))).
      withAction(Action.new(Fn.new{ cycleTile() }).
        withMapping(KeyMapping.new("Up")))

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
    if (target.y >= 0) _map[target.y][target.x] = _tile
    
    checkForAllMatches()

    _tileAllowances[_tile] = _tileAllowances[_tile] - 1

    if (isLevelClear()) {
      loadLevel(_currentLevel + 1)
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
    if (_tileAllowances.all{|allowance| allowance == 0}) {
      loadLevel(_currentLevel)
    }

    while (_tileAllowances[_tile] == 0) {
      cycleTile()
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

  checkForAllMatches() {
    var repeat = false

    for (cell in allCells) {
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
    var tile = _map[cell.y][cell.x]
    var countMatches = 1

    if (tile == null || tile == 9) return false

    var matches = MatchSearcher.new(_map, cell).search()
    if (matches.count >= 3) {
      animateBlocks(matches.map{|match| Block.new(tile, cellsToPixels(match))})
      for (c in matches) {
        _map[c.y][c.x] = null
      }
      return true
    }

    return false
  }

  shiftCellsDown() {
    for (y in (Constants.mapHeight - 1)..1) {
      for (x in 0...Constants.mapWidth) {
        if (_map[y][x] == null && _map[y - 1][x] != null) {
          _map[y][x] = _map[y - 1][x]
          _map[y - 1][x] = null
        }
      }
    }
  }

  animateBlocks(blocks) {
    _animatedBlocks = _animatedBlocks + blocks
  }

  loadLevel(level) {
    _map = List.filled(Constants.mapHeight, null)
    for (y in 0...Constants.mapHeight) {
      _map[y] = List.filled(Constants.mapWidth, null)
    }

    _currentLevel = level

    var levelString = LEVELS[level][0].trim()
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
      if (_map[y + 1][_x] != null) break
      y = y + 1
    }
    return Point.new(_x, y)
  }

  cellsToPixels(v) {
    return Point.new(v.x * Constants.tileSize, (v.y + 1) * Constants.tileSize)
  }

  draw(dt) {
    Gfx.drawMap(_map)
    Gfx.drawCursor(_tile, _x)

    var dropTarget = cellsToPixels(getDropTarget())
    var linex = _x * Constants.tileSize + Constants.tileSize / 2
    Gfx.drawDashedLine(linex, Constants.tileSize, linex, dropTarget.y + Constants.tileSize / 2, _dashOffset)
    Gfx.drawGhostTile(_tile, dropTarget.x, dropTarget.y)

    for (block in _animatedBlocks) {
      Gfx.drawTile(block.tile, block.point.x, block.point.y)
    }

    Gfx.drawTile(0, 310, 80)
    Canvas.print("x %(_tileAllowances[0])", 346, 88, Color.white)
    Gfx.drawTile(1, 310, 130)
    Canvas.print("x %(_tileAllowances[1])", 346, 138, Color.white)
    Gfx.drawTile(2, 310, 180)
    Canvas.print("x %(_tileAllowances[2])", 346, 188, Color.white)

    Canvas.rect(300, 70 + _tile * 50, 85, 44, Color.white)
  }
}
