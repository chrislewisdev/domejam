import "./src/constants" for Constants
import "./src/transitionModes" for LevelStartMode, LevelFailedMode, GameFinishedMode
import "./src/playMode" for PlayMode
import "./src/gameState" for GameState

class GameInstance {
  construct new() {
    _state = GameState.new()
    _play = PlayMode.new(_state, this)
    startNextLevel()
  }

  startNextLevel() {
    if (_state.currentLevel < Constants.levels.count - 1) {
      _mode = LevelStartMode.new(_state, this)
    } else {
      youWin()
    }
  }

  play() {
    _mode = _play
  }

  levelFailed() {
    _mode = LevelFailedMode.new(_state, this)
  }

  youWin() {
    _mode = GameFinishedMode.new()
  }

  update() {
    _mode.update()
  }

  draw(dt) {
    // if (_state.currentLevel >= 0) _play.draw(dt)
    _mode.draw(dt)
  }
}