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

  ###
  Is called each tick/frame.
  ###
  update: =>
    # update method
