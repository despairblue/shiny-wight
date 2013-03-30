View = require 'views/base/view'
TILEDMap = require 'models/TILEDMap'
Player = require 'models/Player'
InputManager = require 'models/InputManager'
SoundManager = require 'models/SoundManager'
PhysicsManager = require 'models/PhysicsManager'
mediator = require 'mediator'
Std = require 'models/Std'
EntitySpawnManager = require 'models/EntitySpawnManager'
Level = require 'models/Level'


module.exports = class HomePageView extends View
  autoRender: yes
  className: 'home-page'
  container: '#page-container'

  initialize: (options) ->
    super
    new Std()
    @skipFrame = true

    # developement only, will be removed in release build
    mediator.PlayWithSounds = confirm("Load Sounds?")

    # the first level
    LEVEL = 'level1'
    mediator.levels[LEVEL] = new Level()

    @physicsManager = new PhysicsManager()
    @soundManager = new SoundManager() if mediator.PlayWithSounds
    @inputManager = new InputManager()

    @EntitySpawnManager = new EntitySpawnManager()

    @loadLevel(LEVEL)

    @subscribeEvent 'mapRendered:'+LEVEL, =>
      @publishEvent 'levelChangeTo:'+LEVEL

  loadLevel: (LEVEL) =>
    map = new TILEDMap("level":LEVEL)
    mediator.levels[LEVEL].gMap = map
    mediator.levels[LEVEL].gMap.load(LEVEL)

    if mediator.PlayWithSounds
      @soundManager.load(LEVEL)

    @subscribeEvent 'levelChangeTo:'+LEVEL, =>
      @setup(LEVEL)


  setup: (LEVEL) =>
    mediator.activeLevel = LEVEL
    @physicsManager.setup()
    @EntitySpawnManager.initialSpawn()
    if mediator.PlayWithSounds
      @subscribeEvent 'soundsLoaded:'+LEVEL, =>
        @soundManager.playSound(LEVEL+'theme',mediator.levels[LEVEL].soundList, 1, true)
        @soundManager.startBackgroundSounds()
        @soundManager.updateBackgroundSounds(mediator.player.position)

    window.requestAnimationFrame @doTheWork


  render: =>
    @canvas = document.createElement 'canvas'
    @ctx = @canvas.getContext '2d'
    @el.appendChild @canvas


  doTheWork: =>
    setTimeout =>
      window.requestAnimationFrame @doTheWork
      @handleInput()
      ent.update() for ent in mediator.entities
      @physicsManager.update()
      @draw()
    , 1000/25


  handleInput: =>
    # get attributes
    actions = @inputManager.get 'actions'
    moveDir = new @physicsManager.Vec2 0, 0

    if actions['move-up']
      moveDir.y -= 1

    if actions['move-down']
      moveDir.y += 1

    if actions['move-left']
      moveDir.x -= 1

    if actions['move-right']
      moveDir.x += 1

    if actions['interact']
      placeholder = true
      @publishEvent 'stopCurrentSounds'
      # code

    if actions['cancel']
      placeholder = true
      # code

    if moveDir.LengthSquared()
      moveDir.Normalize()
      moveDir.Multiply(mediator.player.VELOCITY)

      mediator.player.physBody.SetLinearVelocity moveDir
    else
      mediator.player.physBody.SetLinearVelocity new @physicsManager.Vec2 0, 0

  draw: =>
    # Resize canvas to window size
    @canvas.width  = window.innerWidth/2
    @canvas.height = window.innerHeight

    # get attributes
    tileSize  = mediator.levels[mediator.activeLevel].gMap.get 'tileSize'
    pixelSize = mediator.levels[mediator.activeLevel].gMap.get 'pixelSize'
    numXTiles = mediator.levels[mediator.activeLevel].gMap.get 'numXTiles'
    numYTiles = mediator.levels[mediator.activeLevel].gMap.get 'numYTiles'

    pos = mediator.player.position
    radiusOfSight = 6 * tileSize.x

    sx = (pos.x - radiusOfSight)
    sy = (pos.y - radiusOfSight)
    sw = dw = sh = dh = radiusOfSight * 2 + tileSize.x
    dx = 0
    dy = 0

    sx = 0 if sx < 0
    sy = 0 if sy < 0
    sx = pixelSize.x - sw if sx + sw > pixelSize.x
    sy = pixelSize.y - sh if sy + sh > pixelSize.y

    # @ctx.drawImageTiled (@gMap.get 'canvas'), sx, sy, sw, sh, dx, dy, dw, dh, tileSize.x, tileSize.y
    @ctx.drawImage (mediator.levels[mediator.activeLevel].gMap.get 'canvas'), sx, sy, sw, sh, dx, dy, dw, dh

    for entity in mediator.entities
      entity.render(@ctx, sx, sy)
