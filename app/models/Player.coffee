Entity = require 'models/Entity'
mediator = require 'mediator'

###
The Player
###
module.exports = class Player extends Entity
  # register entity
  mediator.factory['Player'] = this

  animationState: [0, 1, 2, 1]

  constructor: (x, y, width, height, owningLevel, settings) ->

    super x, y, width, height, owningLevel, settings

    @spriteState.creationTime = Date.now()

    @entityDef.x = @position.x
    @entityDef.y = @position.y
    @entityDef.userData.ent = @

    @physBody = @level.physicsManager.addBody @entityDef, @level.b2World
    @physBody.SetLinearVelocity(new @level.physicsManager.Vec2(0, 0))

  kill: =>
    mediator.physicsManager.removeBody @physBody
    @physBody = null
    @killed = true

  load: =>
    tileSet = @tileSet

    img = new Image()
    img.src = tileSet.image

    @set 'atlas':img

  onTouch: (otherBody, point, impulse) =>
    console.log "BAM with #{impulse}" if debug

    return false if not @physBody?
    return false if not otherBody.GetUserData()?

    physOwner = otherBody.GetUserData().ent

    if physOwner?.killed
      return false
    else
      # do smth

  update: =>
    @position.x = @physBody.GetPosition().x if @physBody.GetPosition().x?
    @position.y = @physBody.GetPosition().y if @physBody.GetPosition().y?

  getSpritePacket: =>
    x = Math.floor((Date.now() - @spriteState.creationTime)/@spriteState.animationRate) % @tileSet.tilesX
    y = @spriteState.viewDirection

    x = @spriteState.normal unless @spriteState.moving

    pkt =
      x: x * @tileSet.tilewidth
      y: y * @tileSet.tileheight

  # overwrite render method
  render: (ctx, cx, cy) =>
    tileSet = @tileSet

    animationState = @animationState

    img = @get 'atlas'
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
    dx = dx - @tileSet.offset.x
    dy = dy - @tileSet.offset.y

    ctx.drawImage img, sx, sy, sw, sh, dx, dy, dw, dh


  # override from Entity class
  onPositionChange: ->
    mediator.soundManager.updateBackgroundSounds(@position)
