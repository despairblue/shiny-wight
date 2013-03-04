View = require 'views/base/view'
TILEDMap = require 'models/TILEDMap'

module.exports = class HomePageView extends View
  autoRender: yes
  className: 'home-page'
  container: '#page-container'

  initialize: (options) ->
    super
    @gMap = new TILEDMap()
    @listenTo @gMap, 'change:fullyLoaded', (gMap, fullyLoaded) ->
      setInterval @draw, 1000/25 if fullyLoaded
    @gMap.load('map/level1.json')

  render: ->
    @canvas = document.createElement 'canvas'
    @ctx = @canvas.getContext '2d'
    @el.appendChild @canvas

  draw: () =>
    @canvas.width = window.innerWidth
    @canvas.height = window.innerHeight
    currMapData = @gMap.get 'currMapData'
    tileSize = @gMap.get 'tileSize'
    numXTiles = @gMap.get 'numXTiles'
    numYTiles = @gMap.get 'numYTiles'

    for layer in currMapData.layers
      continue if layer.type isnt 'tilelayer'

      for tID, tileIDX in layer.data
        continue if tID is 0

        tPKT = @gMap.getTilePacket tID
        x = (tileIDX % numXTiles) * tileSize.x
        y = Math.floor(tileIDX / numYTiles) * tileSize.y

        @ctx.drawImage tPKT.img, tPKT.px, tPKT.py, tileSize.x, tileSize.y, x, y, tileSize.x, tileSize.y
