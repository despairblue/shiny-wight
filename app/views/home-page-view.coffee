View = require 'views/base/view'
TILEDMap = require 'models/TILEDMap'

module.exports = class HomePageView extends View
  autoRender: yes
  className: 'home-page'
  container: '#page-container'

  initialize: (options) ->
    super
    @gMap = new TILEDMap()
    @subscribeEvent 'map:fullyLoaded', () ->
      setInterval @draw, 1000/16
    @gMap.load('map/level1.json')

  render: ->
    @canvas = document.createElement 'canvas'
    @ctx = @canvas.getContext '2d'
    @el.appendChild @canvas

  draw: () =>
    return unless @gMap.fullyLoaded

    @canvas.width = window.innerWidth
    @canvas.height = window.innerHeight

    for layer in @gMap.currMapData.layers
      continue if layer.type isnt 'tilelayer'

      for tID, tileIDX in layer.data
        continue if tID is 0

        tPKT = @gMap.getTilePacket tID
        x = (tileIDX % @gMap.numXTiles) * @gMap.tileSize.x
        y = Math.floor(tileIDX / @gMap.numYTiles) * @gMap.tileSize.y

        @ctx.drawImage(tPKT.img, tPKT.px, tPKT.py, @gMap.tileSize.x, @gMap.tileSize.y, x, y, @gMap.tileSize.x, @gMap.tileSize.y)
