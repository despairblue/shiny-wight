###
Loads and renders a level.
@note emits `map:rendered` event when map ist fully rendered
###
module.exports = class TILEDMap
  ###
  @private
  Parses TILED map editor json data
  @param [Object] mapTiledObject the parsed TILED map editor map data
  ###
  @parseMapJSON: (mapTiledObject, callback) =>

    console.log 'Start loading atlasses'

    imgLoadCount = mapTiledObject.tilesets.length

    tilesets =
      for tileset in mapTiledObject.tilesets
        @createTileSet tileset, =>
          imgLoadCount--
          if imgLoadCount <= 0
            callback(tilesets)
          else
            console.log "#{imgLoadCount} tile sets to go. Hang in there!" if debug


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
  @createTileSet: (tileset, callback) =>
    # Load tile set image
    img = new Image()
    img.onload = =>
      callback()
    img.src = 'atlases/' + tileset.image.replace /^.*[\\\/]/, ''

    # create and return metadata object
    ts =
      firstgid: tileset.firstgid
      image: img
      imageheight: tileset.imageheight
      imagewidth: tileset.imagewidth
      tileheight: tileset.tileheight
      tilewidth: tileset.tilewidth
      name: tileset.name
      numXTiles: Math.floor (tileset.imagewidth  / (tileset.tilewidth + tileset.spacing))
      numYTiles: Math.floor (tileset.imageheight / (tileset.tileheight + tileset.spacing))
      spacing: tileset.spacing


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
  @getTilePacket: (tileIndex, tileSets) =>
    pkt =
      img: null
      px: 0
      py: 0

    tile = null

    if tileSets
      for tile in tileSets by -1 when tile.firstgid <= tileIndex
        break

      pkt.img = tile.image
      localIdx = tileIndex - tile.firstgid
      lTileX = Math.floor localIdx % tile.numXTiles
      lTileY = Math.floor localIdx / tile.numXTiles
      pkt.py = lTileY * (tile.tileheight + tile.spacing) + tile.spacing
      pkt.px = lTileX * (tile.tilewidth + tile.spacing) + tile.spacing
    else
      tilesets = @get 'tilesets'
      tileSize = @get 'tileSize'
      for tile in tilesets by -1 when tile.firstgid <= tileIndex
        break

      pkt.img = tile.image
      localIdx = tileIndex - tile.firstgid
      lTileX = Math.floor localIdx % tile.numXTiles
      lTileY = Math.floor localIdx / tile.numXTiles
      pkt.py = lTileY * (tileSize.y + tile.spacing) + tile.spacing
      pkt.px = lTileX * (tileSize.x + tile.spacing) + tile.spacing

    return pkt


  ###
  Renders the map into it's own off screen canvas.
  This means the whol background can be drawn with one single draw
  call instead of hundreads.
  ###
  @render: (mapTiledObject, tilesets) =>
    canvas = document.createElement 'canvas'
    ctx = canvas.getContext '2d'

    canvas.width = mapTiledObject.width * mapTiledObject.tilewidth
    canvas.height = mapTiledObject.height * mapTiledObject.tileheight

    console.log 'Finish loading atlasses'

    for layer in mapTiledObject.layers
      continue if layer.type isnt 'tilelayer'
      continue if layer.name is 'sound' or layer.name is 'physics'

      for tID, tileIDX in layer.data
        continue if tID is 0

        tPKT = @getTilePacket tID, tilesets
        coords =
          x: (tileIDX % mapTiledObject.width) * mapTiledObject.tilewidth
          y: Math.floor(tileIDX / mapTiledObject.width) * mapTiledObject.tileheight

        ctx.drawImage tPKT.img, tPKT.px, tPKT.py, mapTiledObject.tilewidth, mapTiledObject.tileheight, coords.x, coords.y, mapTiledObject.tilewidth, mapTiledObject.tileheight

    return canvas


  @parse: (mapTiledObject, callback) =>
    @parseMapJSON mapTiledObject, (tilesets) =>
      callback( @render(mapTiledObject, tilesets), tilesets )
