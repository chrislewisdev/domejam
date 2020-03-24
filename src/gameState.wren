import "math" for Math, Point
import "./src/constants" for Constants

/**
 * Holds any game info that needs to be shared across other classes, eg level information
 */
class GameState {
  // The map will be represented as a 2D grid, organised row-by-column
  map { _map }
  currentLevel { _currentLevel }
  // The number of each tile permitted to the player per level is kept here as a 3-item array copied from the definition in Constants.levels
  tileAllowances { _tileAllowances }

  getTile(x, y) { _map[y][x] }
  setTile(x, y, tile) { _map[y][x] = tile}
  
  construct new() {
    // Current level starts off as -1 so that when we load (currentLevel + 1) we will correctly load level 0
    _currentLevel = -1
  }

  // Loads a level from the Constants.levels array matching the index provided
  loadLevel(level) {
    // Create a fresh, empty map array
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

    // We can work out how tall/wide the level is by seeing how long each line is, and how many lines there are in the string
    var levelWidth = levelString.indexOf("\n") + 1
    if (levelWidth == 0) levelWidth = levelString.count
    var levelHeight = levelString.split("\n").count

    // Rather than filling up the map from [0][0], we insert the level contents so they are roughly centered on the screen
    var xStart = Math.floor(Constants.mapWidth / 2) - Math.ceil(levelWidth / 2) + 1
    var yStart = Constants.mapHeight - levelHeight

    var x = xStart
    var y = yStart

    // Iterate through all the characters in the level and set the contents of our map array accordingly
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

  // Returns true if the level has been completed by checking for any leftover cells
  isLevelClear() {
    for (y in 0...Constants.mapHeight) {
      for (x in 0...Constants.mapWidth) {
        if (_map[y][x] != null && _map[y][x] != 9) return false
      }
    }
    return true
  }

  // The player has failed the level if it's not yet cleared and has run out of tiles to place
  isLevelFailed() {
    return !isLevelClear() && _tileAllowances.all{|allowance| allowance == 0}
  }

  // Returns a sequence of Points denoting all possible map co-ordinates
  // Useful for iterating through all possible cells in a single loop
  allCells {
    return (0...Constants.mapHeight).map{|y| (0...Constants.mapWidth).map{|x| Point.new(x, y) }.toList}.reduce{|acc, row| acc + row.toList }
  }
}