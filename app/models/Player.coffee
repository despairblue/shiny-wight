Person = require 'models/Person'

module.exports = class Player extends Person
  # what does the Player class need?

# overwrite render method
  render: (ctx) ->
    debugger

    tileSet = @get 'tileSet'

    pos = @get 'position'

    img = @get 'atlas'

    sx = 0
    sy = 3*64
    sw = tileSet.tilewidth
    sh = tileSet.tileheight

    dx = pos.x * 32
    dy = pos.y * 32
    dw = 64
    dh = 64

    ctx.drawImage img, sx, sy, sw, sh, dx, dy, dw, dh
