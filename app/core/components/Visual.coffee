Component = require 'core/components/Component'

###
###
module.exports = class Visual extends Component
  constructor: (@owner) ->
    # set up sane defaults
    @visual = true

    @spriteState =
      moving: false
      viewDirection: 0
      animationRate: 100
      normal: 1

    @atlas = new Image()

    @tileSet =
      tilesX: 0
      tilesY: 0
      tileheight: 0
      tilewidth: 0
      offset:
        x: 0
        y: 0


  getSpritePacket: =>
    x = Math.floor((Date.now() - @owner.creationTime)/@spriteState.animationRate) % @tileSet.tilesX
    y = @spriteState.viewDirection

    x = @spriteState.normal unless @spriteState.moving

    pkt =
      x: x * @tileSet.tilewidth
      y: y * @tileSet.tileheight


  render: (ctx, cx, cy) =>
    spritePkt = @getSpritePacket()

    # position of first pixel at [sx, sy] in atlas
    # determine what tile to use (by viewDirection)
    # iterate through the three animationStates

    sx = spritePkt.x
    sy = spritePkt.y

    # width and height of tile in atlas
    sw = @tileSet.tilewidth
    sh = @tileSet.tileheight

    # position of first pixel at [dx, dy] on canvas
    dx = (@owner.position.x) - cx
    dy = (@owner.position.y) - cy
    dw = @owner.size.x
    dh = @owner.size.y

    # translate to drawing center
    dx = dx - @tileSet.offset.x
    dy = dy - @tileSet.offset.y

    ctx.drawImage @atlas, sx, sy, sw, sh, dx, dy, dw, dh
