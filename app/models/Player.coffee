Person = require 'models/Person'

module.exports = class Player extends Person
  # what does the Player class need?

# overwrite render method
  render: (ctx, cx, cy) ->

    map = (@get 'mediator').map

    tileSet = @get 'tileSet'

    pos = @get 'position'

    img = @get 'atlas'

    # position of first pixel at [sx, sy] in atlas
    sx = 0
    sy = 0
    # with and height of tile in atlas
    sw = tileSet.tilewidth
    sh = tileSet.tileheight

    # position of first pixel at [dx, dy] on canvas
    dx = (pos.x * 32) - cx
    dy = (pos.y * 32) - cy
    dw = 32
    dh = 32

    ctx.drawImage img, sx, sy, sw, sh, dx, dy, dw, dh
