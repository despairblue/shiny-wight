module.exports =


  _initVisual: ->
    @visual = true

    @loadMethods.push @_loadVisual

    @spriteState =
      moving: false
      viewDirection: 0
      creationTime: Date.now()
      animationRate: 100
      normal: 1

    # Must be set in constructor
    @tileSet =
      image: 'path to atlas'
      tilesX: 0
      tilesY: 0
      tileheight: 0
      tilewidth: 0
      offset:
        x: 0
        y: 0


  _loadVisual: ->
    tileSet = @tileSet

    img = new Image()
    ###
      TODO: change tileSet.image in Yeti.json
    ###
    img.src = tileSet.image

    @atlas = img


  getSpritePacket: ->
    x = Math.floor((Date.now() - @spriteState.creationTime)/@spriteState.animationRate) % @tileSet.tilesX
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
