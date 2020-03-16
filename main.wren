import "dome" for Process, Window
import "graphics" for Canvas, Color, ImageData
import "input" for Keyboard
import "math" for Point
import "./controls" for KeyMapping, Action, Controls

var TILE_SIZE = 24
var SPRITES = ImageData.loadFromFile("spritesheet.png")

var MAP_WIDTH = 12
var MAP_HEIGHT = 9

class Game {
  static init() {
    Window.resize(400, 240)
    Canvas.resize(400, 240)

    __game = GameInstance.new()
  }

  static update() {
    if (Keyboard.isKeyDown("Escape")) {
      Process.exit()
    }

    __game.update()
  }

  static draw(dt) {
    Canvas.cls()

    Canvas.rect(0, 0, 400, 240, Color.white)

    __game.draw(dt)
    
    Canvas.rect(0, 0, 288, 240, Color.white)
    Canvas.print("SCORE: 0", 310, 10, Color.white)
  }
}

class MatchSearcher {
  construct new(map, cell) {
    _map = map
    _targetTile = map[cell.y][cell.x]
    _candidates = [cell]
  }

  search() {
    evaluateCandidate(_candidates[0])
    return _candidates
  }

  evaluateCandidate(candidate) {
    var directions = [Point.new(1, 0), Point.new(-1, 0), Point.new(0, 1), Point.new(0, -1)]

    for (d in directions) {
      var potentialCandidate = candidate + d
      if (isTileMatching(potentialCandidate.x, potentialCandidate.y)) {
        _candidates.add(potentialCandidate)
        evaluateCandidate(potentialCandidate)
      }
    }
  }

  isTileMatching(x, y) {
    if (x < 0 || x >= MAP_WIDTH || y < 0 || y >= MAP_HEIGHT) return false

    if (_map[y][x] != _targetTile || _candidates.contains(Point.new(x, y))) return false

    return true
  }
}

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
  }

  moveLeft() {
    if (_x > 0) _x = _x - 1
  }

  moveRight() {
    if (_x < MAP_WIDTH - 1) _x = _x + 1
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
      for (c in matches) {
        _map[c.y][c.x] = null
      }
    }
  }

  initMap() {
    _map = List.filled(MAP_HEIGHT, null)
    for (y in 0...MAP_HEIGHT) {
      _map[y] = List.filled(MAP_WIDTH, null)
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
  }

  getDropTarget() {
    var y = -1
    while (y < MAP_HEIGHT - 1) {
      if (_map[y + 1][_x] != null) break
      y = y + 1
    }
    return Point.new(_x, y)
  }

  cellsToPixels(v) {
    return Point.new(v.x * TILE_SIZE, (v.y + 1) * TILE_SIZE)
  }

  draw(dt) {
    drawMap()
    drawCursor()

    var dropTarget = cellsToPixels(getDropTarget())
    var linex = _x * TILE_SIZE + TILE_SIZE / 2
    drawDashedLine(linex, TILE_SIZE, linex, dropTarget.y + TILE_SIZE / 2, _dashOffset)
    Canvas.rect(dropTarget.x, dropTarget.y, TILE_SIZE, TILE_SIZE, Color.white)
  }

  drawDashedLine(x0, y0, x1, y1, offset) {
    var cursor = Point.new(x0, y0)
    var end = Point.new(x1, y1)
    var stepLength = 12

    if (offset > 0) {
      cursor = cursor + (end - cursor).unit * offset
    }

    while (cursor != end) {
      var delta = end - cursor
      if (delta.length < stepLength) {
        Canvas.line(cursor.x, cursor.y, end.x, end.y, Color.white)
        cursor = end
        break
      }

      var lineEnd = cursor + delta.unit * stepLength / 2
      Canvas.line(cursor.x, cursor.y, lineEnd.x, lineEnd.y, Color.white)
      cursor = cursor + delta.unit * stepLength
    }
  }

  drawMap() {
    for (x in 0...MAP_WIDTH) {
      for (y in 0...MAP_HEIGHT) {
        var tile = _map[y][x]
        if (tile) {
          SPRITES.drawArea(tile * TILE_SIZE, 0, TILE_SIZE, TILE_SIZE, x * TILE_SIZE, (y + 1) * TILE_SIZE)
        }
      }
    }
  }

  drawDebugGrid() {
    for (x in 0...MAP_WIDTH) {
      for (y in 0...MAP_HEIGHT) {
        Canvas.rect(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE, Color.red)
      }
    }
  }

  drawCursor() {
    SPRITES.drawArea(0, 0, TILE_SIZE, TILE_SIZE, _x * TILE_SIZE, 0)
  }
}
