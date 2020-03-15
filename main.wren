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

class GameInstance {
  construct new() {
    initMap()
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

  }

  draw(dt) {
    // drawDebugGrid()

    drawMap()
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
}
