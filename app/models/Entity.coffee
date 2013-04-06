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
  VELOCITY: 400

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

    @size =
      x: width
      y: height


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

  onTouch: (body) =>
    # ...
  ###
  Is called each tick/frame.
  ###
  update: =>
    # update method

  # TODO: reimplement animation
  # ###
  # Move the Entity one tile upwards.
  # @note It won't let `@position.y` be negative.
  # ###
  # moveUp: =>
  #   newPosition =
  #     x: @position.x
  #     y: @position.y - @VELOCITY
  #   newPosition.y = 0 if newPosition.y < 0

  #   if mediator.physicsManager.canIMoveThere(newPosition.x, newPosition.y)
  #     @position = newPosition

  #   @updateViewAndAnimation(0)

  # ###
  # Move the Entity one tile downwards.
  # It won't let @position.y be larger than map.numYTiles.
  # @note This method relies on `mediator.map` being set
  # ###
  # moveDown: =>
  #   # get attributes
  #   pixelSize = @map.get 'pixelSize'

  #   newPosition =
  #     x: @position.x
  #     y: @position.y + @VELOCITY
  #   newPosition.y = pixelSize.y - @size.y if newPosition.y > pixelSize.y - @size.y

  #   if mediator.physicsManager.canIMoveThere(newPosition.x, newPosition.y)
  #     @position = newPosition

  #   @updateViewAndAnimation(2)

  # ###
  # Move the Entity one tile to the right.
  # It won't let @position.y be larger than map.numXTiles.
  # @note This method relies on `mediator.map` being set
  # ###
  # moveRight: =>
  #   # get attributes
  #   pixelSize = @map.get 'pixelSize'

  #   newPosition =
  #     x: @position.x + @VELOCITY
  #     y: @position.y
  #   newPosition.x = pixelSize.x - @size.x if newPosition.x > pixelSize.x - @size.x

  #   if mediator.physicsManager.canIMoveThere(newPosition.x, newPosition.y)
  #     @position = newPosition

  #   @updateViewAndAnimation(1)

  # ###
  # Move the Entity one tile upwards.
  # @note It won't let `@position.x` be negative.
  # ###
  # moveLeft: =>
  #   newPosition =
  #     x: @position.x - @VELOCITY
  #     y: @position.y
  #   newPosition.x = 0 if newPosition.x < 0

  #   if mediator.physicsManager.canIMoveThere(newPosition.x, newPosition.y)
  #     @position = newPosition

  #   @updateViewAndAnimation(3)
