soundPrefix = 'sounds/'
mapPrefix = 'map'

###
@example
  mediator.configurationManager.configure player 'Player'
###
module.exports =

  configure: (object, configuration) ->
    if @[configuration]?
      @[configuration].apply(object)

    else
      console.error "Configuration #{configuration} not found!"

    object

  level1: ->
    @sounds =
      prefix: soundPrefix
      sounds: ['jtTheme.mp3']
      theme: 'level1theme.mp3'
      backgroundSounds: [
        'water.mp3'
        'fire.mp3'
        'wood.mp3'
      ]
    @map =
      prefix: mapPrefix
      file: 'level1.json'


  level2: ->
    @sounds =
      prefix: soundPrefix
      sounds: []
      theme: 'level2theme.mp3'
      backgroundSounds: []
    @map =
      prefix: mapPrefix
      file: 'level2.json'


  level2house1: ->
    @sounds =
      prefix: soundPrefix
      sounds: []
      theme: 'level2theme.mp3'
      themeIntensity: 0.3
      backgroundSounds: []
    @map =
      prefix: mapPrefix
      file: 'level2house1.json'


  level2house2: ->
    @sounds =
      prefix: soundPrefix
      sounds: []
      theme: 'level2theme.mp3'
      themeIntensity: 0.3
      backgroundSounds: []
    @map =
      prefix: mapPrefix
      file: 'level2house2.json'


  level3: ->
    @sounds =
      prefix: soundPrefix
      sounds: []
      theme: 'underground.mp3'
      backgroundSounds: []
    @map =
      prefix: mapPrefix
      file: 'level3.json'


  level4: ->
    @sounds =
      prefix: soundPrefix
      sounds: []
      theme: 'underground.mp3'
      backgroundSounds: []
    @map =
      prefix: mapPrefix
      file: 'level4.json'


  level5: ->
    @sounds =
      prefix: soundPrefix
      sounds: []
      theme: 'level2theme.mp3'
      backgroundSounds: []
    @map =
      prefix: mapPrefix
      file: 'level5.json'


  level6: ->
    @sounds =
      prefix: soundPrefix
      sounds: []
      theme: 'level2theme.mp3'
      backgroundSounds: []
    @map =
      prefix: mapPrefix
      file: 'level6.json'


  level7: ->
    @sounds =
      prefix: soundPrefix
      sounds: []
      theme: 'level2theme.mp3'
      backgroundSounds: []
    @map =
      prefix: mapPrefix
      file: 'level7.json'


  Player: ->
    @velocity = 200

    @tileSet.tilesX = 3
    @tileSet.tilesY = 4
    @tileSet.tileheight = 32
    @tileSet.tilewidth = 32
    @tileSet.offset =
      x: 16
      y: 24

  PlayerSkeleton: ->
    @velocity = 250

    @atlas.src = 'atlases/nick.png'
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
