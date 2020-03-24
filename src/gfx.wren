import "graphics" for Canvas, Color, ImageData
import "math" for Point
import "./src/constants" for Constants

var SPRITES = ImageData.loadFromFile("spritesheet.png")

/**
 * Contains various handy functions for drawing graphics to the screen
 */
class Gfx {
  static sprites { SPRITES }

  // Draws a dashed line from x0/y0 to x1/y1
  // The 'offset' parameter can be used to cycle through values from 0..stepLength and create the illusion of a moving line
  static drawDashedLine(x0, y0, x1, y1, offset) {
    var cursor = Point.new(x0, y0)
    var end = Point.new(x1, y1)
    var stepLength = 12

    if (offset > 0) {
      cursor = cursor + (end - cursor).unit * offset
    }

    // Continue to take 'steps' towards the target, drawing lines as we go, until we reach it
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

  // Draws our game map the screen by iterating through all cells and drawing the matching tile
  static drawMap(map) {
    for (x in 0...Constants.mapWidth) {
      for (y in 0...Constants.mapHeight) {
        var tile = map[y][x]
        // tile will be null for empty cells
        if (tile) {
          // We do (y + 1) because the top row of the screen is reserved for the player cursor and does not contain map data
          drawTile(tile, x * Constants.tileSize, (y + 1) * Constants.tileSize)
        }
      }
    }
  }

  static drawTile(tile, x, y) {
    SPRITES.drawArea(tile * Constants.tileSize, 0, Constants.tileSize, Constants.tileSize, x, y)
  }

  // Draws a 'ghost tile' i.e. a preview of where your tile will drop.
  // The ghost effect is achieved by blacking out every 5th pixel, and using 'cycleOffset'
  // to create an animated effect
  static drawGhostTile(tile, x, y, cycleOffset) {
    drawTile(tile, x, y)
    for (ty in y...y+24) {
      for (tx in x...x+24) {
        if ((ty + tx + cycleOffset) % 5 == 0) Canvas.pset(tx, ty, Color.black)
      }
    }
  }

  // Draws the tile at the top of the screen that the player is about to drop
  static drawCursor(tile, x) {
    drawTile(tile, x * Constants.tileSize, 0)
  }

  // Takes an area of the screen enclosed by x0/y0, x1/y1 and enlarges it times 2.
  // Used for scaling up text.
  static scale2x(x0, y0, x1, y1) {
    for (x in x1..x0) {
      for (y in y1..y0) {
        var pixel = Canvas.pget(x, y)
        Canvas.rectfill(x0 + (x - x0) * 2, y0 + (y - y0) * 2, 2, 2, pixel)
      }
    } 
  }
}