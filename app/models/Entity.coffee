Model = require 'models/base/model'
mediator = require 'mediator'

module.exports = class Entity extends Model
  defaults:
    position:
      x: 0
      y: 0

  animationStep: 0
  viewDirection: 0


  # moveDirection and moveState
  updateViewAndMove: (vd) ->
    if @viewDirection != vd
      @animationStep = 1
      @viewDirection = vd
    else
      @animationStep++

  initialize: ->
    @set 'mediator': (require 'mediator')
    @map = (@get 'mediator').map

    # what about sounds?

  onAction: (Object) =>
    # perform an <Object> specific action

  update: =>
    # update method

# maybe it's better to use move: (direction), where direction is enum{up down left right} ??
# viewDirection {0:up, 1:right, 2:down, 3: left}
  moveUp: =>
    # get attributes
    position = @get 'position'
    position.y--
    position.y = 0 if position.y < 0
    @set position

    # moveDirection and moveState
    @updateViewAndMove(0)


  moveDown: =>
    # get attributes
    numYTiles = @map.get 'numYTiles'

    position = @get 'position'
    position.y++
    position.y = numYTiles if position.y > numYTiles
    @set position

    # moveDirection and moveState
    @updateViewAndMove(2)

  moveRight: =>
    # get attributes
    numXTiles = @map.get 'numXTiles'

    position = @get 'position'
    position.x++
    position.x = numXTiles if position.x > numXTiles
    @set position

    # moveDirection and moveState
    @updateViewAndMove(1)

  moveLeft: =>
    # get attributes
    position = @get 'position'
    position.x--
    position.x = 0 if position.x < 0
    @set position

    # moveDirection and moveState
    @updateViewAndMove(3)
