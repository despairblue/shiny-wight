View = require 'views/base/view'
TILEDMap = require 'models/TILEDMap'
Player = require 'models/Player'
InputManager = require 'models/InputManager'
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

    @subscribeEvent 'map:rendered', =>
      @setup()

    @gMap.load('map/level1.json')

  setup: =>
    @inputManager = new InputManager()

    @MapInitialEntitySpawnManager = new MapInitialEntitySpawnManager()
    @MapInitialEntitySpawnManager.spawn()

    for entity in mediator.entities
      continue if entity.tileSet.name isnt "Player"
      @player = entity
      break

    window.requestAnimationFrame @doTheWork

  render: =>
    @canvas = document.createElement 'canvas'
    @ctx = @canvas.getContext '2d'
    @el.appendChild @canvas


  doTheWork: =>
    setTimeout =>
      window.requestAnimationFrame @doTheWork
      @handleInput()
      @draw()
    , 1000/25


  handleInput: =>
    # get attributes
    actions = @inputManager.get 'actions'
    #position = @player.get 'position'

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
      # code

    if actions['cancle']
      placeholder = true
      # code

    # set attributes
    # @player.set 'position':position

  draw: =>
    # Resize canvas to window size
    @canvas.width  = window.innerWidth
    @canvas.height = window.innerHeight

    # get attributes
    tileSize  = @gMap.get 'tileSize'
    numXTiles = @gMap.get 'numXTiles'
    numYTiles = @gMap.get 'numYTiles'

    pos = @player.position

    sx = (pos.x - 5) * tileSize.x
    sy = (pos.y - 5) * tileSize.y
    sw = dw = 11 * tileSize.x
    sh = dh = 11 * tileSize.y
    dx = 0
    dy = 0

    sx = 0 if sx < 0
    sy = 0 if sy < 0
    sx = numXTiles*tileSize.x if sx > numXTiles*tileSize.x
    sy = numYTiles*tileSize.y if sy > numYTiles*tileSize.y

    @ctx.drawImage (@gMap.get 'canvas'), sx, sy, sw, sh, dx, dy, dw, dh
    for entity in mediator.entities
      entity.render(@ctx, sx, sy)
