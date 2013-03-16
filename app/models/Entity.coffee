Model = require 'models/base/model'
mediator = require 'mediator'

module.exports = class Entity extends Model
  defaults:
    position:
      x: 0
      y: 0

    # what about sounds?

  onAction: (Object) =>
    # perform an <Object> specific action

  update: =>
    # update method

# maybe it's better to use move: (direction), where direction is enum{up down left right} ??
  moveUp: =>
    # get attributes
    position = @get 'position'
    position.y--
    position.y = 0 if position.y < 0
    @set position

  moveDown: =>
    # get attributes
    position = @get 'position'
    position.y++
    @set position

  moveRight: =>
    # get attributes
    position = @get 'position'
    position.x++
    @set position

  moveLeft: =>
    # get attributes
    position = @get 'position'
    position.x--
    position.x = 0 if position.x < 0
    @set position
