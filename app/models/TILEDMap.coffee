Model = require 'models/base/model'

module.exports = class TILEDMap extends Model
  constructor: () ->
    @currMapData = null
    @tileset = []
    @numXTiles = 100
    @numYTiles = 100
    @tileSize =
      x: 64
      y: 64
    @pixelSize =
      x: 64
      y: 64
    @imgLoadCount = 0
    @fullyLoaded = false

  xhrGet: (reqUri, callback) =>
    xhr = new XMLHttpRequest()
    xhr.open 'GET', reqUri, true
    xhr.onload = callback
    xhr.send()

  load: (map) ->
    @xhrGet map, (data) =>
      @parseMapJSON data.target.responseText

  parseMapJSON: (mapJSON) =>
    @currMapData = JSON.parse mapJSON

    @numXTiles = @currMapData.width
    @numYTiles = @currMapData.height

    @tileSize.x = @currMapData.tilewidth
    @tileSize.y = @currMapData.tileheight

    @pixelSize.x = @numXTiles * @tileSize.x
    @pixelSize.y = @numYTiles * @tileSize.y

    @tilesets = for tileset in @currMapData.tilesets
      @createTileSet tileset

  createTileSet: (tileset) =>
    img = new Image()
    img.onload = =>
      @imgLoadCount++
      if @imgLoadCount == @currMapData.tilesets.length
        @fullyLoaded = true
    img.src = 'atlases/' + tileset.image.replace /^.*[\\\/]/, ''

    ts =
      firstgid: tileset.firstgid;
      image: img
      imageheight: tileset.imageheight
      imagewidth: tileset.imagewidth
      name: tileset.name
      numXTiles: Math.floor (tileset.imagewidth / @tileSize.x)
      numYTiles: Math.floor (tileset.imageheight / @tileSize.y)

  getTilePacket: (tileIndex) =>
    pkt =
      img: null
      px: 0
      py: 0

    tile = null

    for tile in @tilesets by -1 when tile.firstgid <= tileIndex
      break

    pkt.img = tile.image
    localIdx = tileIndex - tile.firstgid
    lTileX = Math.floor localIdx % tile.numXTiles
    lTileY = Math.floor localIdx / tile.numYTiles
    pkt.px = lTileX * @tileSize.x
    pkt.py = lTileY * @tileSize.y

    pkt
