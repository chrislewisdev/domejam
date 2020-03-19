import "dome" for Process, Window
import "graphics" for Canvas, Color
import "input" for Keyboard
import "audio" for AudioEngine
import "./src/gameInstance" for GameInstance
import "./src/controls" for Controls, Action, KeyMapping

/*
 * Entry point for our game. All of the 'real' code is in the src folder, this class just gets everything else up and running.
 */
class Game {
  static init() {
    // This game is designed to roughly match the specs of Playdate (https://play.date/)
    // So the screen is 400x240px and black and white only!
    Canvas.resize(400, 240)
    setScale(1)

    __game = GameInstance.new()

    __controls = Controls.new().
      withAction(Action.new(Fn.new{ setScale(1) }).
        withMapping(KeyMapping.new("1"))).
      withAction(Action.new(Fn.new{ setScale(2) }).
        withMapping(KeyMapping.new("2"))).
      withAction(Action.new(Fn.new{ setScale(3) }).
        withMapping(KeyMapping.new("3")))
  }

  static setScale(scale) {
    Window.resize(400 * scale, 240 * scale)
  }

  static update() {
    if (Keyboard.isKeyDown("Escape")) {
      Process.exit()
    }

    __controls.evaluate()
    __game.update()
  }

  static draw(dt) {
    Canvas.cls()

    Canvas.rect(0, 0, 400, 240, Color.white)

    __game.draw(dt)
    
    Canvas.rect(0, 0, 288, 240, Color.white)
    Canvas.print("SCORE: 0", 310, 10, Color.white)
  }
}