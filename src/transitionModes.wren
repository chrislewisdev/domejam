import "graphics" for Canvas, Color
import "./src/gfx" for Gfx
import "./src/constants" for Constants

class LevelStartMode {
  construct new(state, gameInstance) {
    _state = state
    _timer = 100
    _gameInstance = gameInstance
  }

  update() {
    _timer = _timer - 1

    if (_timer <= 0) {
      _state.loadLevel(_state.currentLevel + 1)
      _gameInstance.play()
    }
  }

  draw(dt) {
    Canvas.rectfill(45, 100, 100, 20, Color.black)
    Canvas.rect(45, 100, 100, 20, Color.white)
    Canvas.print("Level %(_state.currentLevel < 8 ? "0" : "")%(_state.currentLevel + 2)/%(Constants.levels.count)", 51, 106, Color.white)
    Gfx.scale2x(45, 100, 165, 120)
  }
}

class LevelFailedMode {
  construct new(state, gameInstance) {
    _state = state
    _timer = 100
    _gameInstance = gameInstance
  }

  update() {
    _timer = _timer - 1

    if (_timer <= 0) {
      _state.loadLevel(_state.currentLevel)
      _gameInstance.play()
    }
  }

  draw(dt) {
    Canvas.rectfill(40, 100, 115, 36, Color.black)
    Canvas.rect(40, 100, 115, 36, Color.white)
    Canvas.print("Out of moves!", 46, 106, Color.white)
    Canvas.print("Try again", 61, 120, Color.white)
    Gfx.scale2x(40, 100, 160, 136)
  }
}

class GameFinishedMode {
  construct new() {}

  update() {}

  draw(dt) {
    Canvas.rectfill(35, 85, 115, 36, Color.black)
    Canvas.rect(35, 85, 115, 36, Color.white)
    Canvas.print("Congrats!", 57, 91, Color.white)
    Canvas.print("You win!", 60, 105, Color.white)
    Gfx.scale2x(35, 85, 155, 121)
  }
}