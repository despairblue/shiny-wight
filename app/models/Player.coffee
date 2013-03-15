Model = require 'models/base/model'

module.exports = class Player extends Model
  defaults:
    position:
      x: 0
      y: 0

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
