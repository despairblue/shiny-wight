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
Mario         = require 'models/Mario'
Gumba         = require 'models/Gumba'
Vec2          = Box2D.Common.Math.b2Vec2

PHYSICS_LOOP  = 1000/60
RENDER_LOOP   = 1000/25


module.exports = class HomePageView extends View
  autoRender: yes
  className: 'home-page'
  container: '#page-container'

  initialize: (options) ->
    super

    @setupDatGui() if debug

    new Std()

    mediator.homepageview = @

    @handleAction = _.debounce @_handleAction, 50, true

    @canvas = document.getElementById 'game-canvas'
    @ctx = @canvas.getContext '2d'

    window.mediator = mediator if debug

    @soundManager = new SoundManager() if mediator.playWithSounds
    @inputManager = new InputManager()
    @dialogManager = new DialogManager()

    now = Date.now()
    @lastPhysicsUpdate = now
    @lastRenderUpdate  = now

    @subscribeEvent 'changeLvl', =>
      console.log 'change to '+mediator.nextLevel if debug
      @setup(mediator.nextLevel)

    # the first level
    level = 'level1'
    @loadLevel level, =>
      @setup level
      window.requestAnimationFrame @doTheWork


  loadLevel: (level, callback) =>
    if mediator.levels[level]?
      callback?()
      return

    mediator.levels[level] = new Level (level), =>
      callback?()


  # loads next levels
  loadNextLevels: =>
    # iterate through MapChanger Entities and load levels they point to
    for entity in mediator.getActiveLevel().entityObjects
      continue if !entity.levelToChangeTo?
      @loadLevel(entity.levelToChangeTo)


  setup: (level) =>
    lvl = mediator.levels[level]

    if lvl.loadCompleted
      mediator.dialogManager.hideDialog()

      mediator.activeLevel = level
      lvl.setup() unless lvl.setupped
      @soundManager.startAll() if mediator.playWithSounds

      @loadNextLevels()
    else
      mediator.dialogManager.showDialog {text: "Sorry, I still need to load some damn cool sound, so please hang in there!"} unless mediator.dialogManager.isDialog()
      setTimeout =>
        @setup level
      , 500


  doTheWork: =>
    window.requestAnimationFrame @doTheWork

    timeNow = Date.now()
    lvl = mediator.getActiveLevel()

    return unless lvl?

    while @lastPhysicsUpdate < timeNow
      # just skip huge time intervals
      if timeNow - @lastPhysicsUpdate > 1000
        @lastPhysicsUpdate = timeNow
      else
        @handleInput()
        lvl.updatePhysics()
        lvl.update()
        @lastPhysicsUpdate += PHYSICS_LOOP

    renderDelte = timeNow - @lastRenderUpdate - RENDER_LOOP
    if renderDelte > 0
      @draw()
      lvl.physicsManager.world.DrawDebugData() if mediator.renderDebug
      @lastRenderUpdate = timeNow

    if debug
      timeToRender = Date.now() - timeNow
      if timeToRender > 40
        console.log "Took #{timeToRender} ms to render frame."


  handleInput: =>
    # get attributes
    actions = @inputManager.get 'actions'
    moveDir = new Vec2 0, 0
    player = mediator.getActiveLevel()?.player

    return unless player?

    if actions['move-up']
      moveDir.y -= 1
      player.spriteState.viewDirection = 0

      # control dialog
      if mediator.dialogManager.isDialog()
        mediator.dialogManager.moveSelectionUp()

    if actions['move-down']
      moveDir.y += 1
      player.spriteState.viewDirection = 2

      # control dialog
      if mediator.dialogManager.isDialog()
        mediator.dialogManager.moveSelectionDown()

    if actions['move-left']
      moveDir.x -= 1
      player.spriteState.viewDirection = 3

    if actions['move-right']
      moveDir.x += 1
      player.spriteState.viewDirection = 1

    if actions['interact']
      @handleAction()

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


  _handleAction: =>
    # only do smth if there is no dialog
    if mediator.dialogManager.isDialog()
      mediator.dialogManager.chooseCurrentSelection()
    else
      player = mediator.getActiveLevel().player
      player.onAction()


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

    for entity in lvl.entityObjects when entity.visual?
      entity.render(@ctx, sx, sy)

    # always draw the player on top of everything again
    lvl.player.render(@ctx, sx, sy)


  setupDatGui: ->
    gui = new dat.GUI()

    gui.remember(mediator)

    # dat.gui synchonizes the properties, so giving it access to activeLevel
    # directly leads to weird behaviour, see onFinishChange below
    activeLevel    = gui.add {activeLevel:''}, 'activeLevel'
    playWithSounds = gui.add mediator, 'playWithSounds'
    blockInput     = gui.add mediator, 'blockInput'
    renderDebug    = gui.add mediator, 'renderDebug'
    disableDialogs = gui.add mediator, 'disableDialogs'

    activeLevel.listen()
    playWithSounds.listen()
    blockInput.listen()
    renderDebug.listen()
    disableDialogs.listen()

    activeLevel.onFinishChange (value) ->
      if mediator.playWithSounds
        mediator.soundManager.stopAll config =
          themeSound: true
          backgroundSounds: true
          sounds: true

      mediator.homepageview.loadLevel value, ->

        mediator.homepageview.setup value
