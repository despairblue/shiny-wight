Person = require 'models/Person'
mediator = require 'mediator'

###
The Player
###
module.exports = class Player extends Person
  # register entity
  mediator.factory['Player'] = this

  animationState: [0, 1, 2, 1]

  constructor: (x, y, width, height, settings) ->

    super x, y, width, height, settings

    @tileSet =
      name: "Player"
      image: "atlases/warrior_m.png"
      imageheight: 4 * @size.height
      imagewidth: 96
      tileheight: @size.width
      tilewidth: @size.height

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

  # overwrite render method
  render: (ctx, cx, cy) =>
    tileSet = @tileSet

    animationState = @animationState

    img = @get 'atlas'

    # position of first pixel at [sx, sy] in atlas
    # determine what tile to use (by viewDirection)
    # iterate through the three animationStates

    sx = (animationState[@animationStep % animationState.length]) * @size.x
    sy = (@viewDirection) * @size.y
    # with and height of tile in atlas
    sw = @size.x
    sh = @size.y

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
