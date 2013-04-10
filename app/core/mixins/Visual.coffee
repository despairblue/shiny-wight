module.exports =

  # Call this in the construcotr before you call super
  _visual_setUp: (pathToAtlas) ->
    # set up sane defaults
    @visual = true

    @spriteState =
      moving: false
      viewDirection: 0
      animationRate: 100
      normal: 1

    @tileSet =
      image: pathToAtlas
      tilesX: 0
      tilesY: 0
      tileheight: 0
      tilewidth: 0
      offset:
        x: 0
        y: 0


  # Call this in the constructor after you call super
  _visual_init: () ->
    @loadMethods.push @_visual_load

  # Will be called when Entity.load is called
  _visual_load: ->
    img = new Image()
    img.src = @tileSet.image

    @atlas = img


  getSpritePacket: ->
    x = Math.floor((Date.now() - @creationTime)/@spriteState.animationRate) % @tileSet.tilesX
    y = @spriteState.viewDirection

    x = @spriteState.normal unless @spriteState.moving

    pkt =
      x: x * @tileSet.tilewidth
      y: y * @tileSet.tileheight


  render: (ctx, cx, cy) ->
    tileSet = @tileSet

    spritePkt = @getSpritePacket()

    # position of first pixel at [sx, sy] in atlas
    # determine what tile to use (by viewDirection)
    # iterate through the three animationStates

    sx = spritePkt.x
    sy = spritePkt.y
    # with and height of tile in atlas
    sw = @tileSet.tilewidth
    sh = @tileSet.tileheight

    # position of first pixel at [dx, dy] on canvas
    dx = (@position.x) - cx
    dy = (@position.y) - cy
    dw = @size.x
    dh = @size.y

    # translate to drawing center
    dx = dx - Math.floor @tileSet.tilewidth / 2
    dy = dy - Math.floor @tileSet.tileheight / 2

    ctx.drawImage @atlas, sx, sy, sw, sh, dx, dy, dw, dh
