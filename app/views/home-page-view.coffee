View = require 'views/base/view'
TILEDMap = require 'models/TILEDMap'
Player = require 'models/Player'
InputManager = require 'models/InputManager'
mediator = require 'mediator'

module.exports = class HomePageView extends View
  autoRender: yes
  className: 'home-page'
  container: '#page-container'

  initialize: (options) ->
    super
    @gMap = new TILEDMap()
    @skipFrame = true

    @listenTo @gMap, 'change:fullyLoaded', (gMap, fullyLoaded) ->
      @setup() if fullyLoaded

    @gMap.load('map/level1.json')

    mediator.map = @gMap

  setup: =>
    @inputManager = new InputManager()
    @player = new Player()

    position =
      x: 2
      y: 7

    @player.set 'position':position

    tileSet =
      image: "atlases/warrior_m.png"
      imageheight: 96
      imagewidth: 144
      name: "player"
      tileheight: 32
      tilewidth: 32

    @player.set 'tileSet':tileSet
    @player.load()

    window.requestAnimationFrame @doTheWork

  render: ->
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
    position = @player.get 'position'

    if actions['move-up']
      @player.moveUp()

    if actions['move-down']
      @player.moveDown()

    if actions['move-left']
      @player.moveLeft()

    if actions['move-right']
      @player.moveRight()

    # set attributes
    # @player.set 'position':position

  draw: =>
    # Resize canvas to window size
    @canvas.width  = window.innerWidth
    @canvas.height = window.innerHeight

    # get attributes
    tileSize = @gMap.get 'tileSize'
    numXTiles = @gMap.get 'numXTiles'
    numYTiles = @gMap.get 'numYTiles'
    pos      = @player.get 'position'

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
    @player.render(@ctx, sx, sy)
