import "audio" for AudioEngine

AudioEngine.load("movement", "sfx/movement.wav")
AudioEngine.load("block-drop", "sfx/block-drop.wav")
AudioEngine.load("match", "sfx/match.wav")
AudioEngine.load("block-disappear", "sfx/block-disappear.wav")

/**
 * This class just contains convenience functions for playing sound effects.
 * Keeping all the audio ID strings in this file alone helps ensure we don't 
 * mis-type them when trying to use them in other files.
 */
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