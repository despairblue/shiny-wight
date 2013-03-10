Model = require 'models/base/model'

module.exports = class TILEDMap extends Model
  defaults:
    currMapData: null
    tileset: []
    numXTiles: 100
    numYTiles: 100
    tileSize:
      x: 64
      y: 64
    pixelSize:
      x: 64
      y: 64
    fullyLoaded: false

  initialize: ->
    super
    @imgLoadCount = 0

  xhrGet: (reqUri, callback) =>
    xhr = new XMLHttpRequest()
    xhr.open 'GET', reqUri, true
    xhr.onload = callback
    xhr.send()


  load: (map) ->
    @xhrGet map, (data) =>
      @parseMapJSON data.target.responseText

  parseMapJSON: (mapJSON) =>
    currMapData = JSON.parse mapJSON
    numXTiles = currMapData.width
    numYTiles = currMapData.height

    tileSize =
      x: currMapData.tileheight
      y: currMapData.tilewidth

    pixelSize =
      x: numXTiles * tileSize.x
      y: numYTiles * tileSize.y

    @set 'currMapData':currMapData
    @set 'numXTiles':currMapData.width
    @set 'numYTiles':currMapData.height
    @set 'tileSize':tileSize
    @set 'pixelSize':pixelSize

    tilesets = for tileset in currMapData.tilesets
      @createTileSet tileset

    @set 'tilesets':tilesets

  createTileSet: (tileset) =>
    currMapData = @get 'currMapData'
    tileSize = @get 'tileSize'

    img = new Image()
    img.onload = =>
      @imgLoadCount++
      if @imgLoadCount == currMapData.tilesets.length
        @set 'fullyLoaded': true
        @publishEvent 'map:fullyLoaded'
    img.src = 'atlases/' + tileset.image.replace /^.*[\\\/]/, ''

    ts =
      firstgid: tileset.firstgid
      image: img
      imageheight: tileset.imageheight
      imagewidth: tileset.imagewidth
      name: tileset.name
      numXTiles: Math.floor (tileset.imagewidth / tileSize.x)
      numYTiles: Math.floor (tileset.imageheight / tileSize.y)

  getTilePacket: (tileIndex) =>
    pkt =
      img: null
      px: 0
      py: 0

    tile = null
    tilesets = @get 'tilesets'
    tileSize = @get 'tileSize'

    for tile in tilesets by -1 when tile.firstgid <= tileIndex
      break

    pkt.img = tile.image
    localIdx = tileIndex - tile.firstgid
    lTileX = Math.floor localIdx % tile.numXTiles
    lTileY = Math.floor localIdx / tile.numYTiles
    pkt.px = lTileX * tileSize.x
    pkt.py = lTileY * tileSize.y

    pkt
