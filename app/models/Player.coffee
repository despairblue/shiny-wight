Entity = require 'models/Entity'
mediator = require 'mediator'

###
The Player
###
module.exports = class Player extends Entity
  # register entity
  mediator.factory['Player'] = this

  animationState: [0, 1, 2, 1]

  constructor: (x, y, width, height, settings) ->

    super x, y, width, height, settings

    @spriteState =
      moving: false
      viewDirection: 0
      creationTime: Date.now()
      animationRate: 1000/10
      normal: 1

    @VELOCITY = 300

    @tileSet =
      name: "Player"
      image: "atlases/warrior_m.png"
      tilesX: 3
      tilesY: 4
      imageheight: 4 * @size.height
      imagewidth: 96
      tileheight: 32
      tilewidth: 32

    @entityDef =
      id: 'Player'
      type: 'dynamic'
      x: @position.x
      y: @position.y
      # make the player's physBody smaller to make movements more plausable
      halfWidth: @size.x / 4
      halfHeight: @size.y / 4
      damping: 0
      angle: 0
      categories: ['']
      collidesWith: ['all']
      userData:
        id: 'Player'
        ent: @

    @physBody = mediator.physicsManager.addBody @entityDef
    @physBody.SetLinearVelocity(new mediator.physicsManager.Vec2(0, 0))

  kill: =>
    mediator.physicsManager.removeBody @physBody
    @physBody = null
    @killed = true

  initialize: ->
    # what?

  load: =>
    tileSet = @tileSet

    img = new Image()
    img.src = tileSet.image

    @set 'atlas':img

  onTouch: (otherBody, point, impulse) =>
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
    dx = dx - Math.floor(sw/2)
    dy = dy - Math.floor((sh/4)*3)

    ctx.drawImage img, sx, sy, sw, sh, dx, dy, dw, dh


  # override from Entity class
  onPositionChange: ->
    mediator.soundManager.updateBackgroundSounds(@position)
