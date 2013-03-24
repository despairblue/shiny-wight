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
    @position.y--
    @position.y = 0 if @position.y < 0

    # moveDirection and moveState
    @updateViewAndAnimation(0)

  ###
  Move the Entity one tile downwards.
  It won't let @position.y be larger than map.numYTiles.
  @note This method relies on `mediator.map` being set
  ###
  moveDown: =>
    # get attributes
    numYTiles = @map.get 'numYTiles'

    @position.y++
    @position.y = numYTiles if @position.y > numYTiles

    # moveDirection and moveState
    @updateViewAndAnimation(2)

  ###
  Move the Entity one tile to the right.
  It won't let @position.y be larger than map.numXTiles.
  @note This method relies on `mediator.map` being set
  ###
  moveRight: =>
    # get attributes
    numXTiles = @map.get 'numXTiles'

    @position.x++
    @position.x = numXTiles if @position.x > numXTiles

    # moveDirection and moveState
    @updateViewAndAnimation(1)

  ###
  Move the Entity one tile upwards.
  @note It won't let `@position.x` be negative.
  ###
  moveLeft: =>
    @position.x--
    @position.x = 0 if @position.x < 0

    # moveDirection and moveState
    @updateViewAndAnimation(3)
