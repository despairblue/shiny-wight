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
    @player = new Player()
    @inputManager = new InputManager()

    @listenTo @gMap, 'change:fullyLoaded', (gMap, fullyLoaded) ->
      setInterval @doTheWork, 1000/25 if fullyLoaded
    @gMap.load('map/level1.json')

    @mediator.map = @gMap

    position =
      x: 2
      y: 7

    @player.set 'position':position

  render: ->
    @canvas = document.createElement 'canvas'
    @ctx = @canvas.getContext '2d'
    @el.appendChild @canvas


  doTheWork: =>
    @handleInput()
    @draw()

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
    pos      = @player.get 'position'

    sx = (pos.x - 5) * tileSize.x
    sy = (pos.y - 5) * tileSize.y
    sw = dw = 5 * 2 * tileSize.x
    sh = dh = 5 * 2 * tileSize.y
    dx = 0
    dy = 0

    sx = 0 if sx < 0
    sy = 0 if sy < 0

    @ctx.drawImage (@gMap.get 'canvas'), sx, sy, sw, sh, dx, dy, dw, dh
