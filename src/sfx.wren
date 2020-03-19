import "audio" for AudioEngine

AudioEngine.load("movement", "sfx/movement.wav")
AudioEngine.load("block-drop", "sfx/block-drop.wav")
AudioEngine.load("match", "sfx/match.wav")
AudioEngine.load("block-disappear", "sfx/block-disappear.wav")

class Sfx {
  static playMovementSound() {
    AudioEngine.play("movement")
  }

  static playBlockDropSound() {
    AudioEngine.play("block-drop")
  }

  static playMatchSound() {
    AudioEngine.play("match")
  }

  static playBlockDisappearSound() {
    AudioEngine.play("block-disappear")
  }
}