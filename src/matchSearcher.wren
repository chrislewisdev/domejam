import "math" for Point
import "./src/constants" for Constants

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
    if (x < 0 || x >= Constants.mapWidth || y < 0 || y >= Constants.mapHeight) return false

    if (_map[y][x] != _targetTile || _candidates.contains(Point.new(x, y))) return false

    return true
  }
}