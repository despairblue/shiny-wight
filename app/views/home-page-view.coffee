View = require 'views/base/view'
TILEDMap = require 'models/TILEDMap'
Player = require 'models/Player'
InputManager = require 'models/InputManager'
SoundManager = require 'models/SoundManager'
mediator = require 'mediator'
MapInitialEntitySpawnManager = require 'models/MapInitialEntitySpawnManager'


module.exports = class HomePageView extends View
  autoRender: yes
  className: 'home-page'
  container: '#page-container'

  initialize: (options) ->
    super
    @gMap = new TILEDMap()
    @skipFrame = true

    @soundManager = new SoundManager()

    @subscribeEvent 'map:rendered', =>
      @setup()

    @gMap.load('map/level1.json')

  setup: =>
    @inputManager = new InputManager()

    @mapInitialEntitySpawnManager = new MapInitialEntitySpawnManager()
    @mapInitialEntitySpawnManager.spawn()

    for entity in mediator.entities
      if entity.tileSet.name is "Player"
        @player = entity
        break

    @soundManager.update(@player.position)
    @soundManager.startBackgroundsSounds()

    window.requestAnimationFrame @doTheWork

  render: =>
    @canvas = document.createElement 'canvas'
    @ctx = @canvas.getContext '2d'
    @el.appendChild @canvas


  doTheWork: =>
    setTimeout =>
      window.requestAnimationFrame @doTheWork
      @handleInput()
      @soundManager.update(@player.position)
      @draw()
    , 1000/25


  handleInput: =>
    # get attributes
    actions = @inputManager.get 'actions'

    if actions['move-up']
      @player.moveUp()

    if actions['move-down']
      @player.moveDown()

    if actions['move-left']
      @player.moveLeft()

    if actions['move-right']
      @player.moveRight()

    if actions['interact']
      placeholder = true
      mediator.publish 'play', 'dummy', 1
      # code

    if actions['cancle']
      placeholder = true
      mediator.publish 'play', 'dundundun', 1


      # code

  draw: =>
    # Resize canvas to window size
    @canvas.width  = window.innerWidth
    @canvas.height = window.innerHeight

    # get attributes
    tileSize  = @gMap.get 'tileSize'
    numXTiles = @gMap.get 'numXTiles'
    numYTiles = @gMap.get 'numYTiles'

    pos = @player.position
    radiusOfSight = 6

    sx = (pos.x - radiusOfSight)
    sy = (pos.y - radiusOfSight)
    sw = dw = sh = dh = radiusOfSight * 2 + 1
    dx = 0
    dy = 0

    sx = 0 if sx < 0
    sy = 0 if sy < 0
    sx = numXTiles - sw if sx + sw > numXTiles
    sy = numYTiles - sh if sy + sh > numYTiles

    @ctx.drawImageTiled (@gMap.get 'canvas'), sx, sy, sw, sh, dx, dy, dw, dh, tileSize.x, tileSize.y
    for entity in mediator.entities
      entity.render(@ctx, sx * tileSize.x, sy * tileSize.y)
