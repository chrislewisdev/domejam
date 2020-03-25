import "math" for Point
import "./src/constants" for Constants

/**
 * This class implements a basic depth-first graph search that is used to check for matches in our grid.
 * For more information on depth-first search check https://en.wikipedia.org/wiki/Depth-first_search
 */
class MatchSearcher {
  // Must be initialised with a reference to our map array and the co-ordinates of the cell to start with
  construct new(map, cell) {
    _map = map
    _targetTile = map[cell.y][cell.x]
    _candidates = [cell]
  }

  // Starts up a search and returns a match if found as a list containing the co-ordinates of all matching cells
  search() {
    evaluateCandidate(_candidates[0])
    return _candidates
  }

  // For the given 'candidate' cell in the map, proceeds to check if any tiles surrounding it match the targeted tile
  // For any that do match, recursively continues to search for more matches in that direction
  evaluateCandidate(candidate) {
    var directions = [Point.new(1, 0), Point.new(-1, 0), Point.new(0, 1), Point.new(0, -1)]

    for (d in directions) {
      var potentialCandidate = candidate + d
      if (isTileMatching(potentialCandidate.x, potentialCandidate.y)) {
        // The _candidates list tracks all matching cells as well as prevents us from checking the same cell twice
        _candidates.add(potentialCandidate)
        evaluateCandidate(potentialCandidate)
      }
    }
  }

  // Returns true if the tile at the given co-ordinates matches what we're looking for
  isTileMatching(x, y) {
    // Is this co-ordinate actually inside the grid?
    if (x < 0 || x >= Constants.mapWidth || y < 0 || y >= Constants.mapHeight) return false

    // Ignore if the tile is the wrong type or we've already found this match
    if (_map[y][x] != _targetTile || _candidates.contains(Point.new(x, y))) return false

    return true
  }
}