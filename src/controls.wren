import "input" for Keyboard

/**
 * Defines a simple model for input handling in the game. It goes like so:
 * An Action defines a function that can be triggered by any number of KeyMappings, with 
 * an associated cooldown (so that actions don't repeat too often while you hold a key)
 * The Controls class groups together any number of Actions so that they can be evaluated each frame
 * using the 'evaluate' function.
 */

class KeyMapping {
  construct new(key) {
    _key = key
  }

  isActivated() {
    return Keyboard.isKeyDown(_key)
  }
}

class Action {
  construct new(action) {
    _action = action
    _mappings = []
    _cooldown = 0
    _cooldownLength = 15
  }

  construct new(action, cooldownLength) {
    _action = action
    _mappings = []
    _cooldown = 0
    _cooldownLength = cooldownLength
  }

  // Enables us to build actions like Action.new().withMapping(mapping1).withMapping(mapping2)
  withMapping(mapping) {
    _mappings.add(mapping)
    return this
  }

  evaluate() {
    if (_mappings.any{|mapping| mapping.isActivated()}) {
      // If a key is held, the cooldown will prevent it from firing every frame
      if (_cooldown == 0) {
        _cooldown = _cooldownLength
        _action.call()
      } else {
        _cooldown = _cooldown - 1
      }
    } else {
      // If no keys are being pressed, we can reset the cooldown, so that when they press again the action will fire
      _cooldown = 0
    }
  }
}

class Controls {
  construct new() {
    _actions = []
  }

  withAction(action) {
    _actions.add(action)
    return this
  }

  evaluate() {
    for (action in _actions) {
      action.evaluate()
    }
  }
}