import "math" for Math, Point
import "./src/constants" for Constants

class GameState {
  map { _map }
  currentLevel { _currentLevel }
  tileAllowances { _tileAllowances }

  getTile(x, y) { _map[y][x] }
  setTile(x, y, tile) { _map[y][x] = tile}
  
  construct new() {
    _currentLevel = -1
  }

  loadLevel(level) {
    _map = List.filled(Constants.mapHeight, null)
    for (y in 0...Constants.mapHeight) {
      _map[y] = List.filled(Constants.mapWidth, null)
    }

    _currentLevel = level

    var levelString = Constants.levels[level][0].trim()
    _tileAllowances = List.filled(3, 0)
    _tileAllowances[0] = Constants.levels[level][1]
    _tileAllowances[1] = Constants.levels[level][2]
    _tileAllowances[2] = Constants.levels[level][3]

    var levelWidth = levelString.indexOf("\n") + 1
    if (levelWidth == 0) levelWidth = levelString.count
    var levelHeight = levelString.split("\n").count

    var xStart = Math.floor(Constants.mapWidth / 2) - Math.ceil(levelWidth / 2) + 1
    var yStart = Constants.mapHeight - levelHeight

    var x = xStart
    var y = yStart

    for (char in levelString) {
      if (char == "_") {
        x = x + 1
      } else if (char == "\n") {
        x = xStart
        y = y + 1
      } else if (char == "s") {
        _map[y][x] = 0
        x = x + 1
      } else if (char == "d") {
        _map[y][x] = 1
        x = x + 1
      } else if (char == "b") {
        _map[y][x] = 2
        x = x + 1
      } else if (char == "x") {
        _map[y][x] = 9
        x = x + 1
      }
    }
  }

  isLevelClear() {
    for (y in 0...Constants.mapHeight) {
      for (x in 0...Constants.mapWidth) {
        if (_map[y][x] != null && _map[y][x] != 9) return false
      }
    }
    return true
  }

  isLevelFailed() {
    return !isLevelClear() && _tileAllowances.all{|allowance| allowance == 0}
  }

  allCells {
    return (0...Constants.mapHeight).map{|y| (0...Constants.mapWidth).map{|x| Point.new(x, y) }.toList}.reduce{|acc, row| acc + row.toList }
  }
}