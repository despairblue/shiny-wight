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
      'arrowLeft': 37
      'arrowUp': 38
      'arrowRight': 39
      'arrowDown': 40
      'enter': 13
      'escape': 27
      'space': 32


  initialize: () =>
    # get attributes
    keyCodes = @get 'keyCodes'

    # set up key bindings
    @bind keyCodes['w'], 'move-up'
    @bind keyCodes['a'], 'move-left'
    @bind keyCodes['s'], 'move-down'
    @bind keyCodes['d'], 'move-right'
    @bind keyCodes['arrowUp'], 'move-up'
    @bind keyCodes['arrowLeft'], 'move-left'
    @bind keyCodes['arrowDown'], 'move-down'
    @bind keyCodes['arrowRight'], 'move-right'
    @bind keyCodes['enter'], 'interact'
    @bind keyCodes['space'], 'interact'
    @bind keyCodes['escape'], 'cancel'

    # register event listener
    window.addEventListener 'keydown', @onKeyDownEvent
    window.addEventListener 'keyup', @onKeyUpEvent

    @otherKeyPressed = false

  ###
  Set the corresponding action in the actions array to true

      Pressing `w` will set `move-up` to true on an qwerty keyboard
  @params [Event] event Event Object
  ###
  onKeyDownEvent: (event) =>
    # get attributes
    code     = event['keyCode']

    if @otherKeyPressed
      @onKeyUpEvent(@otherKeyPressed)

    bindings = @get 'bindings'
    actions  = @get 'actions'

    action = bindings[code]

    if action
      actions[action] = true

    # set attributes
    @set 'actions':actions

    @otherKeyPressed = event


  ###
  Set the corresponding action in the actions array to false

      Releasing `w` will set `move-up` to false on an qwerty keyboard
  @params [Event] event Event Object
  ###
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

  ###
  Bind a key code to an action.
  @example How to bind `w` to the `move-up` action
    @bind 87, 'move-up'
  ###
  bind: (key, action) =>
    # get attributes
    bindings = @get 'bindings'

    bindings[key] = action

