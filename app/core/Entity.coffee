Module = require 'core/Module'
mediator = require 'mediator'

###
Base class for all entities

@example How to subclass Entity
  module.exports = class VisibleEntity extends Entity
    onAction: (object): ->
      # do something
###
module.exports = class Entity extends Module
  constructor: (owningLevel, object) ->
    super
    @_listeners     = []

    # Copy all properties from the TILED object
    @[prop] = content for prop, content of object.properties

    @level        = owningLevel
    @creationTime = Date.now()
    @name         = object.name

    ###
    @property [Integer]
    Entity' velocity
    Standard velocity = 10
    ###
    @velocity = 400

    ###
    @property [Object] The entity's position in pixels
    @option position [Integer] x y coordinate
    ###
    @position =
      x: Math.floor object.x
      y: Math.floor object.y

    ###
    @property [Object] The entity's size
    ###
    @size =
      x: Math.floor object.width
      y: Math.floor object.height

    @entityDef =
      type: 'dynamic'
      x: @position.x
      y: @position.y
      width: @size.x
      height: @size.y
      ellipse: false
      isSensor: false
      userData:
        ent: @

    @entityDef.ellipse = object.ellipse ? false
    @entityDef.isSensor = object.properties.isSensor ? false
    @entityDef.type = object.properties.physicsType ? 'dynamic'

    @physBody = @level.physicsManager.addBody @entityDef, @level.b2World
    @physBody.SetLinearVelocity(new @level.physicsManager.Vec2(0, 0))


  ###
  Adds an event listener.
  @param [string] type The event type to listen to.
  @param [function] listener The Callback to be invoked.
  ###
  addListener: (type, listener) =>
    @_listeners[type] = [] unless @_listeners[type]?
    @_listeners[type].push listener

  ###
  Adds an event listener that will only be invoked once
  @see Entity#addListener
  ###
  addOneTimeListener: (type, listener) =>
    @addListener type, (event) =>
      # call listener only once
      @removeListener event.type, event.listener
      listener.call @, event

  ###
  Fires an event, invoking all it's listeners.
  @param [string] event The event type.
  ###
  fire: (event) =>
    event = type:event if typeof event is "string"
    event.target = this unless event.target?

    throw new Error("Event object missing 'type' property.") unless event.type

    if @_listeners[event.type] instanceof Array
      listeners = @_listeners[event.type]
      callbacks = []

      # call all listeners in the context of this object
      # and remove them if they return true
      for listener in listeners
        callbacks.push listener

      for callback in callbacks
        event.listener = callback
        callback.call @, event
        delete event.callback


  ###
  Removes an event listener.
  @param [string] type The event type.
  @param [function] listner The Callback to be removed.
  ###
  removeListener: (type, listener) =>
    if @_listeners[type] instanceof Array
      listeners = @_listeners[type]

      for l, i in listeners
        if l is listener
          listeners.splice i, 1
          break


  ###
  Is called if the Player stands in front of this Entity and want's to interact with it.
  @param [Object] player
    The Player.
  ###
  onAction: (player) =>
    # perform an <Object> specific action


  load: =>
    @fire 'load'


  kill: =>
    @fire 'kill'

    # TODO: go to physics mixin
    @level.physicsManager.world.DestroyBody(@physBody)

    @level.removeEntity @

    # TODO: implement
    # @destructor()


  ###
  Is called when the Entity moved
  @note removed publish event 'anyEntityhere:moved' for much(!) better performance
  ###
  onPositionChange: =>
    # method to be overloaded


  # TODO: move to physics mixin
  onTouch: =>
    event =
      type: 'touch'
      arguments: arguments
    @fire event


  onTouchBegin: =>
    @fire 'touchBegin'


  onTouchEnd: =>
    event =
      type: 'touchEnd'
      arguments: arguments
    @fire event


  # I won't move no matter what! Don't even try it.
  makeMeStatic: () =>
    # TODO: move to physics mixin
    @oldVelocity = _.clone @physBody.GetLinearVelocity()
    @physBody.SetType Box2D.Dynamics.b2Body.b2_staticBody


  # Light as a feather...
  makeMeDynamic: () =>
    # TODO: move to physics mixin
    @physBody.SetType Box2D.Dynamics.b2Body.b2_dynamicBody
    @physBody.SetAwake true
    @physBody.SetLinearVelocity @oldVelocity


  ###
  Is called each tick/frame.
  ###
  update: =>
    # TODO: move to physics mixin
    @position.x = @physBody.GetPosition().x if @physBody.GetPosition().x?
    @position.y = @physBody.GetPosition().y if @physBody.GetPosition().y?

    @fire 'update'


  # TODO: move input mixin
  blockInput: () =>
    @scriptable.addTask ->
      require('mediator').blockInput = true
      return true

    return @


  unblockInput: () =>
    @scriptable.addTask ->
      require('mediator').blockInput = false
      return true

    return @
