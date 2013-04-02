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

    window.homepageview = @ if debug
    mediator.PlayWithSounds = true
    mediator.PlayWithSounds = confirm("Load Sounds?") if debug

    @skipFrame = true
    @physicsManager = new PhysicsManager()
    @soundManager = new SoundManager() if mediator.PlayWithSounds
    @inputManager = new InputManager()
    @entitySpawnManager = new EntitySpawnManager()

    # the first level
    level = 'level1'

    if mediator.PlayWithSounds
      @subscribeEvent 'soundsLoaded', =>
        # TODO: hardcoded themesong
        @soundManager.playSound(mediator.activeLevel+'theme',mediator.levels[level].soundList, 1, true)
        @soundManager.startBackgroundSounds()
        @soundManager.updateBackgroundSounds(mediator.player.position)

    @loadLevel(level)

  loadLevel: (level) =>
    mediator.nextLevel = level

    map = new TILEDMap 'callWhenRendered': =>
      @setup level

      if mediator.PlayWithSounds
        @soundManager.load(level)

    mediator.levels[level] = new Level (level + '.json'), =>
      mediator.levels[level].gMap = map
      mediator.levels[level].gMap.load(level)



  setup: (level) =>
    @soundManager.stopAll()
    mediator.activeLevel = level
    mediator.entities = []
    @physicsManager.setup()
    @entitySpawnManager.initialSpawn()

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
    player = mediator.player

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
      placeholder = true
      @loadLevel('level2')
      # code

    if actions['cancel']
      placeholder = true
      # code

    if moveDir.LengthSquared()
      moveDir.Normalize()
      moveDir.Multiply(player.VELOCITY)

      player.physBody.SetLinearVelocity moveDir
      player.onPositionChange(mediator.player.position) if mediator.PlayWithSounds
      player.spriteState.moving = true
    else
      player.physBody.SetLinearVelocity new @physicsManager.Vec2 0, 0
      player.spriteState.moving = false

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
