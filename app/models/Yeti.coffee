Entity = require 'models/Entity'
mediator = require 'mediator'

module.exports = class Yeti extends Entity

  mediator.factory['Yeti'] = this


  constructor: (x, y, width, height, owningLevel, settings) ->
    settings.ellipse = true

    super x, y, width/2, height/2, owningLevel, settings

    @size.x = width
    @size.y = height

    @spriteState.creationTime = Date.now()
    ###
      TODO: uncomment properties if needed
    ###
    ###
      Is the object Static or Dynamic?
    ###
    # settings.physicsType = 'static'
    settings.physicsType = 'dynamic'


    ###
      If the entity is a Sensor it means that the player can walk through it
    ###
    #settings.isSensor    = true

    @physBody.SetLinearVelocity(new @level.physicsManager.Vec2(0, 0))




  load: =>
    tileSet = @tileSet

    img = new Image()
    ###
      TODO: change tileSet.image in Yeti.json
    ###
    img.src = tileSet.image

    @atlas = img


  onTouchBegin: (body, point) =>
    console.log  'Hey, why do you start bumping into me?'
    @spriteState.moving = true
    @makeMeStatic() if body.GetUserData()?.ent.name is 'Player'


  onTouch: (body, point, impulse) =>
    console.log 'Hey, why do you keep touching me?'


  onTouchEnd: (body, point) =>
    console.log 'Hey, why do you stop touching me?'
    @spriteState.moving = false
    @makeMeDynamic() if body.GetUserData()?.ent.name is 'Player'


  update: =>
    ###
      synchronize the visial position with the physical one
    ###
    super


  onAction: (player) =>
    mediator.dialogManager.showDialog {"text":"PIKACHU!!!","options":["Yeah...right."]}


  getSpritePacket: =>
    x = Math.floor((Date.now() - @spriteState.creationTime)/@spriteState.animationRate) % @tileSet.tilesX
    y = @spriteState.viewDirection

    x = @spriteState.normal unless @spriteState.moving

    pkt =
      x: x * @tileSet.tilewidth
      y: y * @tileSet.tileheight


  render: (ctx, cx, cy) =>
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
