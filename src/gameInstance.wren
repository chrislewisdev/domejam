import "graphics" for Canvas, Color
import "math" for Point
import "./src/controls" for KeyMapping, Action, Controls
import "./src/matchSearcher" for MatchSearcher
import "./src/constants" for Constants
import "./src/gfx" for Gfx

class GameInstance {
  construct new() {
    initMap()

    _x = 5
    _moveCooldown = 0

    _controls = Controls.new().
      withAction(Action.new(Fn.new{ moveLeft() }).
        withMapping(KeyMapping.new("Left"))).
      withAction(Action.new(Fn.new{ moveRight() }).
        withMapping(KeyMapping.new("Right"))).
      withAction(Action.new(Fn.new{ placeBlock() }).
        withMapping(KeyMapping.new("Z")))

    _dashOffset = 0

    _animatedBlocks = []
  }

  moveLeft() {
    if (_x > 0) _x = _x - 1
  }

  moveRight() {
    if (_x < Constants.mapWidth - 1) _x = _x + 1
  }

  placeBlock() {
    var target = getDropTarget()
    if (target.y >= 0) _map[target.y][target.x] = 0
    checkForMatch(target)
  }

  checkForMatch(cell) {
    var tile = _map[cell.y][cell.x]
    var countMatches = 1

    var matches = MatchSearcher.new(_map, cell).search()
    if (matches.count >= 3) {
      animateBlocks(matches)
      for (c in matches) {
        _map[c.y][c.x] = null
      }
    }
  }

  animateBlocks(cells) {
    _animatedBlocks = _animatedBlocks + cells.map{|cell| cellsToPixels(cell)}
  }

  initMap() {
    _map = List.filled(Constants.mapHeight, null)
    for (y in 0...Constants.mapHeight) {
      _map[y] = List.filled(Constants.mapWidth, null)
    }
    _map[6][3] = 0
    _map[6][5] = 1
    _map[6][7] = 2
    _map[7][6] = 1
  }

  update() {
    _controls.evaluate()

    _dashOffset = _dashOffset + 0.5
    if (_dashOffset > 12) _dashOffset = 0

    for (block in _animatedBlocks) {
      var newPosition = moveTowards(block, Point.new(0, 0), 6)
      block.x = newPosition.x
      block.y = newPosition.y
    }
    _animatedBlocks = _animatedBlocks.where{|block| block != Point.new(0, 0)}.toList
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
    Gfx.drawCursor(_x)

    var dropTarget = cellsToPixels(getDropTarget())
    var linex = _x * Constants.tileSize + Constants.tileSize / 2
    Gfx.drawDashedLine(linex, Constants.tileSize, linex, dropTarget.y + Constants.tileSize / 2, _dashOffset)
    Canvas.rect(dropTarget.x, dropTarget.y, Constants.tileSize, Constants.tileSize, Color.white)

    for (block in _animatedBlocks) {
      Gfx.sprites.drawArea(0, 0, Constants.tileSize, Constants.tileSize, block.x, block.y)
    }
  }
}
