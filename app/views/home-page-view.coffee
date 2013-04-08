View          = require 'views/base/view'
InputManager  = require 'models/InputManager'
SoundManager  = require 'models/SoundManager'
DialogManager = require 'models/DialogManager'
mediator      = require 'mediator'
Std           = require 'models/Std'
Level         = require 'models/Level'
Player        = require 'models/Player'
MapChanger    = require 'models/MapChanger'
Event         = require 'models/Event'
Yeti          = require 'models/Yeti'
Vec2          = Box2D.Common.Math.b2Vec2

GAME_LOOP     = 1000/60
PHYSICS_LOOP  = 1000/60
RENDER_LOOP   = 1000/25



module.exports = class HomePageView extends View
  autoRender: yes
  className: 'home-page'
  container: '#page-container'

  initialize: (options) ->
    super
    new Std()

    @canvas = document.getElementById 'game-canvas'
    @ctx = @canvas.getContext '2d'

    window.homepageview = @ if debug
    window.mediator = mediator if debug
    mediator.playWithSounds = true
    mediator.playWithSounds = confirm("Load Sounds?") if debug

    @soundManager = new SoundManager() if mediator.playWithSounds
    @inputManager = new InputManager()
    @dialogManager = new DialogManager()

    now = Date.now()
    @lastPhysicsUpdate = now
    @lastGameUpdate    = now
    @lastRenderUpdate  = now

    @subscribeEvent 'changeLvl', =>
      console.log 'change to '+mediator.activeLevel if debug
      @setup(mediator.activeLevel)

    # the first level
    level = 'level1'
    @loadLevel level, =>
      @setup level
      window.requestAnimationFrame @doTheWork


  loadLevel: (level, rest...) =>
    return if mediator.levels[level]?

    mediator.levels[level] = new Level (level + '.json'), =>
      rest[0]() if rest[0]


  # loads next levels
  loadNextLevels: =>
    # iterate through MapChanger Entities and load levels they point to
    for entity in mediator.getActiveLevel().entityObjects
      continue if !entity.levelToChangeTo?
      @loadLevel(entity.levelToChangeTo)


  setup: (level) =>
    lvl = mediator.levels[level]

    mediator.activeLevel = level
    lvl.setup() unless lvl.setupped
    @soundManager.startAll() if mediator.playWithSounds

    # window.requestAnimationFrame @doTheWork
    @loadNextLevels()


  doTheWork: =>
    window.requestAnimationFrame @doTheWork
    # setTimeout =>
    timeNow = Date.now()
    lvl = mediator.getActiveLevel()

    while @lastPhysicsUpdate < timeNow
      lvl.updatePhysics()
      @lastPhysicsUpdate += PHYSICS_LOOP

    while @lastGameUpdate < timeNow
      @handleInput()
      lvl.update()
      @lastGameUpdate += GAME_LOOP

    while @lastRenderUpdate < timeNow
      @draw()
      lvl.physicsManager.world.DrawDebugData() if debug
      @lastRenderUpdate += RENDER_LOOP
    # , 1000/10


  handleInput: =>
    # get attributes
    actions = @inputManager.get 'actions'
    moveDir = new Vec2 0, 0
    player = mediator.getActiveLevel().player

    if actions['move-up']
      moveDir.y -= 1
      player.spriteState.viewDirection = 0

    if actions['move-down']
      moveDir.y += 1
      player.spriteState.viewDirection = 2

    if actions['move-left']
      moveDir.x -= 1
      player.spriteState.viewDirection = 3

    if actions['move-right']
      moveDir.x += 1
      player.spriteState.viewDirection = 1

    if actions['interact']
      player.onAction()

    if actions['cancel']
      placeholder = true

    if moveDir.LengthSquared() and not mediator.blockInput
      moveDir.Normalize()
      moveDir.Multiply(player.velocity)

      player.physBody.SetLinearVelocity moveDir
      player.onPositionChange() if mediator.playWithSounds
      player.spriteState.moving = true
    else
      player.physBody.SetLinearVelocity new Vec2 0, 0
      player.spriteState.moving = false


  draw: =>
    lvl = mediator.getActiveLevel()

    # get attributes
    numXTiles = lvl.mapTiledObject.width
    numYTiles = lvl.mapTiledObject.height
    tileSize  =
      x: lvl.mapTiledObject.tileheight
      y: lvl.mapTiledObject.tilewidth
    pixelSize =
      x: numXTiles * tileSize.x
      y: numYTiles * tileSize.y

    pos = lvl.player.position
    radiusOfSight = 6 * tileSize.x

    sx = (pos.x - radiusOfSight)
    sy = (pos.y - radiusOfSight)
    sw = dw = sh = dh = radiusOfSight * 2 + tileSize.x
    dx = 0
    dy = 0

    sx = pixelSize.x - sw if sx + sw > pixelSize.x
    sy = pixelSize.y - sh if sy + sh > pixelSize.y
    sx = 0 if sx < 0
    sy = 0 if sy < 0

    # check boundaries, level might be smaller than radius of sight
    sw = dw = pixelSize.x if sw - sx > pixelSize.x
    sh = dh = pixelSize.y if sh - sy > pixelSize.y

    # Resize canvas to window size
    @canvas.width  = sw
    @canvas.height = sh

    # @ctx.drawImageTiled (@gMap.get 'canvas'), sx, sy, sw, sh, dx, dy, dw, dh, tileSize.x, tileSize.y
    @ctx.drawImage (lvl.mapCanvas), sx, sy, sw, sh, dx, dy, dw, dh

    for entity in lvl.entityObjects
      entity.render(@ctx, sx, sy)

    # always draw the player on top of everything again
    lvl.player.render(@ctx, sx, sy)
