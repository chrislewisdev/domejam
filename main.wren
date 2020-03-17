import "dome" for Process, Window
import "graphics" for Canvas, Color
import "input" for Keyboard
import "./src/gameInstance" for GameInstance

/*
 * Entry point for our game. All of the 'real' code is in the src folder, this class just gets everything else up and running.
 */
class Game {
  static init() {
    // This game is designed to roughly match the specs of Playdate (https://play.date/)
    // So the screen is 400x240px and black and white only!
    Window.resize(400, 240)
    Canvas.resize(400, 240)

    __game = GameInstance.new()
  }

  static update() {
    if (Keyboard.isKeyDown("Escape")) {
      Process.exit()
    }

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