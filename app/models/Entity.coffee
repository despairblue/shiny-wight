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
  @property [Object] The entity's position
  @option position [Integer] x x coordinate
  ###
  position:
    x: 0
    y: 0

  ###
  @property [String] The entity's StepSound
  ###
  stepSound: 'defaultStep'

  ###
  @property [Integer]
  What sprite to draw
  ###
  animationStep: 0

  ###
  @property [Integer]
  In what direction the entity looks

      0:up
      1:right
      2:down
      3:left
  ###
  viewDirection: 0

  ###
  @private
  Initializes the new Entity.
  Will try to get the map from the mediator.
  @note Make sure to call `TILEDMap.load(path)` before instantiating any Entities.
  ###
  initialize: ->
    @map = mediator.map

  ###
  @private
  @param [Integer] vd
    the view direction. Can be one of 0, 1, 2 or 3.
  @see [Entity#viewDirection]
  Updates the animationStep counter and viewDirection.
  If the entity goes into the same direction, only update animationStep
  If not it will reset the animationStep counter and update the viewDirection
  ###
  updateViewAndAnimation: (vd) =>
    if @viewDirection != vd
      @animationStep = 1
      @viewDirection = vd
    else
      @animationStep++
      # this prevents Player sounding like a mashinegun
      # it's an ugly hack an should be done better later
      if (@animationStep % 3) == 0
        mediator.publish 'play', @stepSound, 0.5

  ###
  Is called if the Player stands in front of this Entity and want's to interact with it.
  @param [Object] player
    The Player.
  ###
  onAction: (player) =>
    # perform an <Object> specific action

  ###
  Is called each tick/frame.
  ###
  update: =>
    # update method

  ###
  Move the Entity one tile upwards.
  @note It won't let `@position.y` be negative.
  ###
  moveUp: =>
    newPosition =
      x: @position.x
      y: @position.y - 1
    newPosition.y = 0 if newPosition.y < 0

    if mediator.physicsManager.canIMoveThere(newPosition.x, newPosition.y)
      @position = newPosition

    # moveDirection and animationState
    @updateViewAndAnimation(0)

  ###
  Move the Entity one tile downwards.
  It won't let @position.y be larger than map.numYTiles.
  @note This method relies on `mediator.map` being set
  ###
  moveDown: =>
    # get attributes
    numYTiles = @map.get 'numYTiles'

    newPosition =
      x: @position.x
      y: @position.y + 1
    newPosition.y = numYTiles - 1 if newPosition.y > numYTiles - 1

    if mediator.physicsManager.canIMoveThere(newPosition.x, newPosition.y)
      @position = newPosition

    # moveDirection and animationState
    @updateViewAndAnimation(2)

  ###
  Move the Entity one tile to the right.
  It won't let @position.y be larger than map.numXTiles.
  @note This method relies on `mediator.map` being set
  ###
  moveRight: =>
    # get attributes
    numXTiles = @map.get 'numXTiles'

    newPosition =
      x: @position.x + 1
      y: @position.y
    newPosition.x = numXTiles - 1 if newPosition.x > numXTiles - 1

    if mediator.physicsManager.canIMoveThere(newPosition.x, newPosition.y)
      @position = newPosition

    # moveDirection and animationState
    @updateViewAndAnimation(1)

  ###
  Move the Entity one tile upwards.
  @note It won't let `@position.x` be negative.
  ###
  moveLeft: =>
    newPosition =
      x: @position.x - 1
      y: @position.y
    newPosition.x = 0 if newPosition.x < 0

    if mediator.physicsManager.canIMoveThere(newPosition.x, newPosition.y)
      @position = newPosition

    # moveDirection and animationState
    @updateViewAndAnimation(3)