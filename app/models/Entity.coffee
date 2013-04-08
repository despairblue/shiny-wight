Model = require 'models/base/model'
mediator = require 'mediator'

###
Base class for all entities

@example How to subclass Entity
  module.exports = class VisibleEntity extends Entity
    onAction: (object): ->
      # do something
###
module.exports = class Entity extends Model

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
  What sprite to draw
  ###
  animationStep: 0

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

  ###
  @property [Integer]
  In what direction the entity looks

      0:up
      1:right
      2:down
      3:left
  ###
  viewDirection: 0

  constructor: (x, y, width, height, owningLevel, settings) ->
    super

    @[prop] = content for prop, content of settings

    @level = owningLevel

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

    @tasks = []
    @moving =
      up: false
      down: false
      right: false
      left: false

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



  ###
  @private
  Initializes the new Entity.
  Will try to get the map from the mediator.
  @note Make sure to call `TILEDMap.load(path)` before instantiating any Entities.
  ###
  initialize: ->
    @map = mediator.levels[mediator.activeLevel].gMap

  # TODO: reimplement...
  # ###
  # @private
  # @param [Integer] vd
  #   the view direction. Can be one of 0, 1, 2 or 3.
  # @see [Entity#viewDirection]
  # Updates the animationStep counter and viewDirection.
  # If the entity goes into the same direction, only update animationStep
  # If not it will reset the animationStep counter and update the viewDirection
  # ###
  # updateViewAndAnimation: (vd) =>
  #   if @viewDirection != vd
  #     @animationStep = 1
  #     @viewDirection = vd
  #   else
  #     @animationStep++
  #     if mediator.PlayWithSounds
  #       @onPositionChange()

  ###
  Is called if the Player stands in front of this Entity and want's to interact with it.
  @param [Object] player
    The Player.
  ###
  onAction: (player) =>
    # perform an <Object> specific action


  ###
  Is called when the Entity moved
  @note removed publish event 'anyEntityhere:moved' for much(!) better performance
  ###
  onPositionChange: =>
    # method to be overloaded


  load: =>
    # ..


  render: =>
    # ..


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


  moveDown: (pixel) =>
    console.error 'argument must be an positive integer' if pixel < 0
    @tasks.push (context) ->
      context.targetPos =
        x: context.position.x
        y: context.position.y + pixel
      context.moving.down = true
      context.spriteState.moving = true
      context.spriteState.viewDirection = 2


  moveUp: (pixel) =>
    console.error 'argument must be an positive integer' if pixel < 0
    @tasks.push (context) ->
      context.targetPos =
        x: context.position.x
        y: context.position.y - pixel
      context.moving.up = true
      context.spriteState.moving = true
      context.spriteState.viewDirection = 0


  moveRight: (pixel) =>
    console.error 'argument must be an positive integer' if pixel < 0
    @tasks.push (context) ->
      context.targetPos =
        x: context.position.x + pixel
        y: context.position.y
      context.moving.right = true
      context.spriteState.moving = true
      context.spriteState.viewDirection = 1


  moveLeft: (pixel) =>
    console.error 'argument must be an positive integer' if pixel < 0
    @tasks.push (context) ->
      context.targetPos =
        x: context.position.x - pixel
        y: context.position.y
      context.moving.left = true
      context.spriteState.moving = true
      context.spriteState.viewDirection = 3


  stopMovement: (pixel) =>
    @physBody.SetLinearVelocity(new @level.physicsManager.Vec2(0, 0))
    @moving.down        = false
    @moving.up          = false
    @moving.left        = false
    @moving.right       = false
    @spriteState.moving = false


  ###
  Is called each tick/frame.
  ###
  update: =>
    @position.x = @physBody.GetPosition().x if @physBody.GetPosition().x?
    @position.y = @physBody.GetPosition().y if @physBody.GetPosition().y?

    if @moving.down
      if @position.y > @targetPos.y
        @stopMovement()
      else
        @physBody.SetLinearVelocity(new @level.physicsManager.Vec2(0, @velocity))
    else if @moving.up
      if @position.y < @targetPos.y
        @stopMovement()
      else
        @physBody.SetLinearVelocity(new @level.physicsManager.Vec2(0, -@velocity))
    else if @moving.right
      if @position.x > @targetPos.x
        @stopMovement()
      else
        @physBody.SetLinearVelocity(new @level.physicsManager.Vec2(@velocity, 0))
    else if @moving.left
      if @position.x < @targetPos.x
        @stopMovement()
      else
        @physBody.SetLinearVelocity(new @level.physicsManager.Vec2(-@velocity, 0))
    else
      task = @tasks.shift()
      task(@) if task


  addTask: (task) =>
    @tasks.push task
