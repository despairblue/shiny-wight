# Mostly taken from https://code.google.com/p/gritsgame/

Model = require 'models/base/model'

module.exports = class InputManager extends Model
  defaults:
    bindings: {}
    actions: {}
    presses: {}
    locks: {}
    delayedKeyup: []
    keyCodes:
      'a': 65
      'w': 87
      'd': 68
      's': 83

  initialize: () =>
    # get attributes
    keyCodes = @get 'keyCodes'

    # set up key bindings
    @bind keyCodes['w'], 'move-up'
    @bind keyCodes['a'], 'move-left'
    @bind keyCodes['s'], 'move-down'
    @bind keyCodes['d'], 'move-right'

    # register event listener
    window.addEventListener 'keydown', @onKeyDownEvent
    window.addEventListener 'keyup', @onKeyUpEvent

  onKeyDownEvent: (event) =>
    # get attributes
    bindings = @get 'bindings'
    actions  = @get 'actions'
    code     = event['keyCode']

    action = bindings[code]

    if action
      actions[action] = true

    # set attributes
    @set 'actions':actions

  onKeyUpEvent: (event) =>
    # get attributes
    bindings = @get 'bindings'
    actions  = @get 'actions'
    code     = event['keyCode']

    action = bindings[code]

    if action
      actions[action] = false

    # set attributes
    @set 'actions':actions

  bind: (key, action) =>
    # get attributes
    bindings = @get 'bindings'

    bindings[key] = action

