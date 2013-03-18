Model = require 'models/base/model'
mediator = require 'mediator'

module.exports = class Entity extends Model
  position:
    x: 0
    y: 0

  animationStep: 0
  viewDirection: 0


  updateViewAndMove: (vd) ->
    if @viewDirection != vd
      @animationStep = 1
      @viewDirection = vd
    else
      @animationStep++

  initialize: ->
    @set 'mediator': (require 'mediator')
    @map = (@get 'mediator').map

  onAction: (Object) =>
    # perform an <Object> specific action

  update: =>
    # update method

# viewDirection {0:up, 1:right, 2:down, 3: left}
  moveUp: =>
    # get attributes
    position = @position

    position.y--
    position.y = 0 if position.y < 0

    mediator.publish 'play', 'test'

    # moveDirection and moveState
    @updateViewAndMove(0)


  moveDown: =>
    # get attributes
    numYTiles = @map.get 'numYTiles'
    position = @position

    position.y++
    position.y = numYTiles if position.y > numYTiles

    # moveDirection and moveState
    @updateViewAndMove(2)

  moveRight: =>
    # get attributes
    numXTiles = @map.get 'numXTiles'
    position = @position

    position.x++
    position.x = numXTiles if position.x > numXTiles

    # moveDirection and moveState
    @updateViewAndMove(1)

  moveLeft: =>
    # get attributes
    position = @position

    position.x--
    position.x = 0 if position.x < 0

    # moveDirection and moveState
    @updateViewAndMove(3)
