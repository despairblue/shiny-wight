Person = require 'models/Person'

module.exports = class Player extends Person
  # what does the Player class need?

  animationState : [0, 1, 2, 1]

# overwrite render method
  render: (ctx, cx, cy) ->

    map = (@get 'mediator').map

    tileSet = @get 'tileSet'

    pos = @get 'position'

    img = @get 'atlas'

    # position of first pixel at [sx, sy] in atlas
    # determine what tile to use (by viewDirection)
    # iterate through the three walkingStates



    sx = (@animationState[@animationStep % @animationState.length])*tileSet.tilewidth
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
