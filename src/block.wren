/**
 * This class is mainly used for drawing the blocks that animate towards the corner of the screen
 * when a match has been made. It just describes one of the three tiles from the game, and a
 * screen position.
 */
class Block {
  tile { _tile }
  point { _point }
  point=(value) { _point = value }
  
  construct new(tile, point) {
    _tile = tile
    _point = point
  }
}