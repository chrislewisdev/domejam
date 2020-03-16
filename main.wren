import "dome" for Process, Window
import "graphics" for Canvas, Color, ImageData
import "input" for Keyboard

var TILE_SIZE = 24
var SPRITES = ImageData.loadFromFile("spritesheet.png")

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

class KeyMapping {
  construct new(key) {
    _key = key
  }

  isActivated() {
    return Keyboard.isKeyDown(_key)
  }
}

class Action {
  construct new(action) {
    _action = action
    _mappings = []
    _cooldown = 0
  }

  withMapping(mapping) {
    _mappings.add(mapping)
    return this
  }

  evaluate() {
    if (_mappings.any{|mapping| mapping.isActivated()}) {
      if (_cooldown == 0) {
        _cooldown = 10
        _action.call()
      } else {
        _cooldown = _cooldown - 1
      }
    } else {
      _cooldown = 0
    }
  }
}

class GameInstance {
  construct new() {
    initMap()

    _x = 5
    _moveCooldown = 0

    _left = Action.new(Fn.new{ moveLeft() }).
              withMapping(KeyMapping.new("Left"))
    _right = Action.new(Fn.new{ moveRight() }).
              withMapping(KeyMapping.new("Right"))
  }

  moveLeft() {
    if (_x > 0) _x = _x - 1
  }

  moveRight() {
    if (_x < 11) _x = _x + 1
  }

  initMap() {
    _map = List.filled(10, null)
    for (y in 0...10) {
      _map[y] = List.filled(12, null)
    }
    _map[6][3] = 0
    _map[6][5] = 1
    _map[6][7] = 2
  }

  update() {
    _left.evaluate()
    _right.evaluate()
  }

  draw(dt) {
    drawMap()
    drawCursor()
  }

  drawMap() {
    for (x in 0...12) {
      for (y in 0...10) {
        var tile = _map[y][x]
        if (tile) {
          SPRITES.drawArea(tile * TILE_SIZE, 0, TILE_SIZE, TILE_SIZE, x * TILE_SIZE, y * TILE_SIZE)
        }
      }
    }
  }

  drawDebugGrid() {
    for (x in 0...(288 / TILE_SIZE)) {
      for (y in 0...(240 / TILE_SIZE)) {
        Canvas.rect(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE, Color.red)
      }
    }
  }

  drawCursor() {
    SPRITES.drawArea(0, 0, TILE_SIZE, TILE_SIZE, _x * TILE_SIZE, 0)
  }
}
