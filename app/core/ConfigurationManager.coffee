# Use like `ConfigurationManager.player.apply(your_player_object)`
module.exports =


  Player: ->
    @velocity = 200

    @tileSet.tilesX = 3
    @tileSet.tilesY = 4
    @tileSet.tileheight = 32
    @tileSet.tilewidth = 32
    @tileSet.offset =
      x: 16
      y: 24


  Mario: ->
    @tileSet.image = 'atlases/mario.png'
    @tileSet.tilesX = 3
    @tileSet.tilesY = 4
    @tileSet.tileheight = 32
    @tileSet.tilewidth = 32
    @tileSet.offset =
      x: 14
      y: 24

  Yeti: ->
    @velocity = 200

    @tileSet.image = 'atlases/yetis.png'
    @tileSet.tilesX = 3
    @tileSet.tilesY = 4
    @tileSet.tileheight = 32
    @tileSet.tilewidth = 32
    @tileSet.offset =
      x: 0
      y: 0


