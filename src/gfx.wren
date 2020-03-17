import "graphics" for Canvas, Color, ImageData
import "math" for Point
import "./src/constants" for Constants

var SPRITES = ImageData.loadFromFile("spritesheet.png")

class Gfx {
  static sprites { SPRITES }

  static drawDashedLine(x0, y0, x1, y1, offset) {
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

  static drawMap(map) {
    for (x in 0...Constants.mapWidth) {
      for (y in 0...Constants.mapHeight) {
        var tile = map[y][x]
        if (tile) {
          SPRITES.drawArea(tile * Constants.tileSize, 0, Constants.tileSize, Constants.tileSize, x * Constants.tileSize, (y + 1) * Constants.tileSize)
        }
      }
    }
  }

  static drawDebugGrid() {
    for (x in 0...Constants.mapWidth) {
      for (y in 0...Constants.mapHeight) {
        Canvas.rect(x * Constants.tileSize, y * Constants.tileSize, Constants.tileSize, Constants.tileSize, Color.red)
      }
    }
  }

  static drawCursor(x) {
    SPRITES.drawArea(0, 0, Constants.tileSize, Constants.tileSize, x * Constants.tileSize, 0)
  }
}