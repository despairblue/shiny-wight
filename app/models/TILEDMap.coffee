Model = require 'models/base/model'
mediator = require 'mediator'

###
Loads and renders a level.
@note emits `map:rendered` event when map ist fully rendered
###
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
    canvas: null
    ctx: null

  ###
  @private
  Initializes an instance.
  ###
  initialize: ->
    super
    @imgLoadCount = 0
    canvas = document.createElement 'canvas'
    ctx = canvas.getContext '2d'
    @set 'canvas':canvas
    @set 'ctx':ctx
    @listenTo @, 'change:fullyLoaded', @render
    mediator.map = @

  ###
  Starts a XMLHttpRequest and calls the given callback when finished loading.
  @param [String] reqUri URI to the file to be loaded
  @param [Function] callback Callback function
  @todo move to a library
  ###
  xhrGet: (reqUri, callback) ->
    xhr = new XMLHttpRequest()
    xhr.open 'GET', reqUri, true
    xhr.onload = callback
    xhr.send()

  ###
  Loads the map, parses it and renders it
  @param [String] map URI that points to the json output of TILED map editor
  ###
  load: (map) =>
    @xhrGet map, (data) =>
      @parseMapJSON data.target.responseText

  ###
  @private
  Parses TILED map editor json data
  @param [JSON] mapJSON the TILED map editor json data
  ###
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

  ###
  @private
  Loads an atlas referenced from the map file and returns it
  @param [Object] tileset a tileset from the map json
  @return [Object] most important data from that tileset
  @example The returned Object:
    ts =
      firstgid: …    # look at https://github.com/bjorn/tiled/wiki/TMX-Map-Format
      image: …       # the loaded atlas image
      imageheight: … # the atlas's height in pixels
      imagewidth: …  # the atlas's width in pixels
      name: …        # the atlas's name
      numXTiles: …   # number of tiles in x direction
      numYTiles: …   # number of tiles in y direction
  ###
  createTileSet: (tileset) =>
    currMapData = @get 'currMapData'
    tileSize = @get 'tileSize'

    img = new Image()
    img.onload = =>
      @imgLoadCount++
      if @imgLoadCount == currMapData.tilesets.length
        @set 'fullyLoaded': true
    img.src = 'atlases/' + tileset.image.replace /^.*[\\\/]/, ''

    ts =
      firstgid: tileset.firstgid
      image: img
      imageheight: tileset.imageheight
      imagewidth: tileset.imagewidth
      name: tileset.name
      numXTiles: Math.floor (tileset.imagewidth / tileSize.x)
      numYTiles: Math.floor (tileset.imageheight / tileSize.y)

  ###
  @private
  Takes a tile ID and returns the tile's atlas and position
  @param [Integer] tileIndex a tile ID
  @return [Object] the tile's atlas and position
  @example the returned Object:
    pkt =
      img: … # the atlas where the tile is situated
      px: …  # x value of the top left corner in pixels
      py: …  # y value of the top left corner in pixels
  ###
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

  ###
  Renders the map into it's own off screen canvas.
  This means the whol background can be drawn with one single draw
  call instead of hundreads.
  ###
  render: () =>
    currMapData = @get 'currMapData'
    tileSize = @get 'tileSize'
    numXTiles = @get 'numXTiles'
    numYTiles = @get 'numYTiles'
    canvas = @get 'canvas'
    ctx = @get 'ctx'

    canvas.width = numXTiles * tileSize.x
    canvas.height = numYTiles * tileSize.y

    for layer in currMapData.layers
      continue if layer.type isnt 'tilelayer'
      continue if layer.name is 'sound'

      for tID, tileIDX in layer.data
        continue if tID is 0

        tPKT = @getTilePacket tID
        coords =
          x: (tileIDX % numXTiles) * tileSize.x
          y: Math.floor(tileIDX / numYTiles) * tileSize.y

        ctx.drawImage tPKT.img, tPKT.px, tPKT.py, tileSize.x, tileSize.y, coords.x, coords.y, tileSize.x, tileSize.y

    @publishEvent 'map:rendered'
