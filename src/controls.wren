import "input" for Keyboard

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
  }

  withMapping(mapping) {
    _mappings.add(mapping)
    return this
  }

  evaluate() {
    if (_mappings.any{|mapping| mapping.isActivated()}) {
      if (_cooldown == 0) {
        _cooldown = 10
        _action.call()
      } else {
        _cooldown = _cooldown - 1
      }
    } else {
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