import "dome" for Process, Window
import "graphics" for Canvas, Color
import "input" for Keyboard
import "audio" for AudioEngine
import "./src/gameInstance" for GameInstance, GameState
import "./src/controls" for Controls, Action, KeyMapping
import "./src/gfx" for Gfx

/*
 * Entry point for our game. All of the 'real' code is in the src folder, this class just gets everything else up and running.
 */
class Game {
  static init() {
    // This game is designed to roughly match the specs of Playdate (https://play.date/)
    // So the screen is 400x240px and black and white only!
    Canvas.resize(400, 240)
    setScale(1)

    __started = false

    __game = GameInstance.new()

    __controls = Controls.new().
      withAction(Action.new(Fn.new{ setScale(1) }).
        withMapping(KeyMapping.new("1"))).
      withAction(Action.new(Fn.new{ setScale(2) }).
        withMapping(KeyMapping.new("2"))).
      withAction(Action.new(Fn.new{ setScale(3) }).
        withMapping(KeyMapping.new("3"))).
      withAction(Action.new(Fn.new{ startGame() }).
        withMapping(KeyMapping.new("Z")).
        withMapping(KeyMapping.new("X")))
  }

  static setScale(scale) {
    Window.resize(400 * scale, 240 * scale)
  }

  static startGame() {
    if (!__started) __started = true
  }

  static update() {
    if (Keyboard.isKeyDown("Escape")) {
      Process.exit()
    }

    __controls.evaluate()

    if (__started) __game.update()
  }

  static draw(dt) {
    Canvas.cls()

    Canvas.rect(0, 0, 400, 240, Color.white)
    
    Canvas.rect(0, 0, 288, 240, Color.white)

    if (__started) {
      __game.draw(dt)
    } else {
      Canvas.print("Clean", 60, 60, Color.white)
      Canvas.print("That", 80, 75, Color.white)
      Canvas.print("Castle!", 100, 90, Color.white)
      Gfx.scale2x(60, 60, 160, 100)

      Canvas.print("press z/x to start", 80, 180, Color.white)
    }
  }
}