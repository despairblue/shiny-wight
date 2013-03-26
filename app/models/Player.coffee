Person = require 'models/Person'
mediator = require 'mediator'

###
The Player
###
module.exports = class Player extends Person
  # register entity
  mediator.factory['Player'] = this

  animationState : [0, 1, 2, 1]

  tileSet:
    name: "Player"
    image: "atlases/warrior_m.png"
    imageheight: 96
    imagewidth: 144
    tileheight: 32
    tilewidth: 32


  # overwrite render method
  render: (ctx, cx, cy) =>

    tileSet = @tileSet

    animationState = @animationState

    pos = @position

    img = @get 'atlas'

    # position of first pixel at [sx, sy] in atlas
    # determine what tile to use (by viewDirection)
    # iterate through the three animationStates

    sx = (animationState[@animationStep % animationState.length])*tileSet.tilewidth
    sy = (@viewDirection)*tileSet.tileheight
    # with and height of tile in atlas
    sw = tileSet.tilewidth
    sh = tileSet.tileheight

    # position of first pixel at [dx, dy] on canvas
    dx = (pos.x * 32) - cx
    dy = (pos.y * 32) - cy
    dw = 32
    dh = 32

    ctx.drawImage img, sx, sy, sw, sh, dx, dy, dw, dh


  # override from Entity class
  publishPositionChangeEvent: =>
    @publishEvent 'player:moved'
