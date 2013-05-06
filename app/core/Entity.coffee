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
    @loadMethods = []
    @updateMethods = []
    @unloadMethods = []

    # TODO: move to physics mixin
    @onTouchMethods      = []
    @onTouchEndMethods   = []
    @onTouchBeginMethods = []

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
  Is called if the Player stands in front of this Entity and want's to interact with it.
  @param [Object] player
    The Player.
  ###
  onAction: (player) =>
    # perform an <Object> specific action


  load: =>
    # call all load methods
    method.apply(@) for method in @loadMethods


  kill: =>
    method.apply @ for method in @unloadMethods

    # TODO: go to physics mixin
    @level.physicsManager.world.DestroyBody(@physBody)

    @level.removeEntity @


  ###
  Is called when the Entity moved
  @note removed publish event 'anyEntityhere:moved' for much(!) better performance
  ###
  onPositionChange: =>
    # method to be overloaded


  # TODO: move to physics mixin
  onTouch: =>
    method.apply @, arguments for method in @onTouchMethods


  onTouchBegin: =>
    method.apply @, arguments for method in @onTouchBeginMethods


  onTouchEnd: =>
    method.apply @, arguments for method in @onTouchEndMethods


  makeMeStatic: () =>
    @oldVelocity = _.clone @physBody.GetLinearVelocity()
    @physBody.SetType Box2D.Dynamics.b2Body.b2_staticBody


  makeMeDynamic: () =>
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

    # call all update methods
    method.apply(@) for method in @updateMethods


  # TODO: move to taskable mixin
  addTask: (task) =>
    @tasks.push ->
      task.apply @
      return true


  # TODO: move input mixin
  blockInput: () =>
    @tasks.push ->
      require('mediator').blockInput = true
      return true

    return @


  unblockInput: () =>
    @tasks.push ->
      require('mediator').blockInput = false
      return true

    return @
