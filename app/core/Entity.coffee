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

  ###
  @property [Object] The entity's position in pixels
  @option position [Integer] x y coordinate
  ###
  position:
    x: 0
    y: 0

  ###
  @property [Object] The entity's size
  ###
  size:
    x: 0
    y: 0


  ###
  @property [Integer]
  Entity' velocity
  Standart velocity = 10
  ###
  velocity: 400

  entityDef:
    ellipse: false
    type: "dynamic"
    x: 0
    y: 0
    width: 0
    height: 0
    userData:
      ent: null


  # TODO: refactor configuration loading and clean up the constructor
  constructor: (x, y, width, height, owningLevel, settings) ->
    super
    @loadMethods = []
    @updateMethods = []
    @unloadMethods = []

    @[prop] = content for prop, content of settings

    @level = owningLevel
    @creationTime = Date.now()

    @position =
      x: x
      y: y

    @size.x = width

    @size =
      x: width
      y: height

    @entityDef =
      ellipse: false
      type: "dynamic"
      x: 0
      y: 0
      width: 0
      height: 0
      userData:
        ent: null

    @entityDef.x = @position.x
    @entityDef.y = @position.y
    @entityDef.width = width
    @entityDef.height = height
    @entityDef.userData.ent = @
    @entityDef.ellipse = true if settings.ellipse
    @entityDef.type = settings.physicsType if settings.physicsType
    @entityDef.isSensor = true if settings.isSensor

    @physBody = @level.physicsManager.addBody @entityDef, @level.b2World
    @physBody.SetLinearVelocity(new @level.physicsManager.Vec2(0, 0))


  loadSettings: (settings) =>
    @[prop] = content for prop, content of settings


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
  onTouch: (body, point, impulse) =>
    # ...


  onTouchBegin: (body, point) =>
    # ...


  onTouchEnd: (body, point) =>
    # ...


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

    checkPosition = false

    # TODO not all entities need the following block.. actually the fewest entities need this
    # so move it into a subclass to increase performance
    @counter +=1
    if @counter % 10 == 0
      @counter = 1
      if Date.now() - @positionCheckTimer > 2000
        checkPosition = true
        @positionCheckTimer == Date.now()


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


  unblockInput: () =>
    @tasks.push ->
      require('mediator').blockInput = false
      return true

