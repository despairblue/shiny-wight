Person = require 'models/Person'
mediator = require 'mediator'

module.exports = class Player extends Person
  # register entity
  mediator.factory['Player'] = this

  #initialize: ->
   # @set 'mediator': (require 'mediator')
   # @map = (@get 'mediator').map
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

    #map = (@get 'mediator').map

    tileSet = @tileSet

    animationState = @animationState

    pos = @position

    img = @get 'atlas'

    # position of first pixel at [sx, sy] in atlas
    # determine what tile to use (by viewDirection)
    # iterate through the three walkingStates



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
