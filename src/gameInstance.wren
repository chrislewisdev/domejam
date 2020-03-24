import "./src/constants" for Constants
import "./src/transitionScreens" for LevelStartScreen, LevelFailedScreen, GameFinishedScreen
import "./src/playScreen" for PlayScreen
import "./src/gameState" for GameState

/**
 * This class co-ordinates our game state as we transition between level start screens and actual gameplay.
 */
class GameInstance {
  construct new() {
    // The GameState needs to be shared across our various screens to store common data like what level we are on
    _state = GameState.new()
    startNextLevel()
  }

  // Below: functions to switch between each screen type

  startNextLevel() {
    // This function is also reponsible for identifying when we have reached the end of the game, in the below if
    if (_state.currentLevel < Constants.levels.count - 1) {
      // Note that each screen receives a reference to 'this' object that can be used to invoke screen changes
      _screen = LevelStartScreen.new(_state, this)
    } else {
      youWin()
    }
  }

  play() {
    _screen = PlayScreen.new(_state, this)
  }

  levelFailed() {
    _screen = LevelFailedScreen.new(_state, this)
  }

  youWin() {
    _screen = GameFinishedScreen.new()
  }

  // Update/draw functions simply defer to the current screen type we are display
  update() {
    _screen.update()
  }
  draw(dt) {
    _screen.draw(dt)
  }
}