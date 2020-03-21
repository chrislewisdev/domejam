class Block {
  tile { _tile }
  point { _point }
  point=(value) { _point = value }
  
  construct new(tile, point) {
    _tile = tile
    _point = point
  }
}