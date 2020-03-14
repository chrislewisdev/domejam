import "dome" for Process, Window
import "graphics" for Canvas, Color, ImageData
import "input" for Keyboard

var TILE_SIZE = 24

var SPRITES = ImageData.loadFromFile("spritesheet.png")

class Game {
    static init() {
      Window.resize(400, 240)
      Canvas.resize(400, 240)
    }
    static update() {
      if (Keyboard.isKeyDown("Escape")) {
        Process.exit()
      }
    }
    static draw(dt) {
      Canvas.cls()

      Canvas.rect(0, 0, 400, 240, Color.white)

      for (x in 0...(288 / TILE_SIZE)) {
        for (y in 0...(240 / TILE_SIZE)) {
          Canvas.rect(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE, Color.red)
        }
      }

      SPRITES.drawArea(0, 0, TILE_SIZE, TILE_SIZE, 4 * TILE_SIZE, 4 * TILE_SIZE)

      Canvas.rect(0, 0, 288, 240, Color.white)
      Canvas.print("SCORE: 0", 310, 10, Color.white)
    }
}
