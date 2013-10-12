mediator = Chaplin.mediator

soundPrefix = 'gameassets/sounds/'
mapPrefix = 'gameassets/map'

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

    # player should look at you
    @visual.spriteState.viewDirection = 2

    @visual.atlas.src = 'gameassets/atlases/warrior_m.png'
    @visual.tileSet.tilesX = 3
    @visual.tileSet.tilesY = 4
    @visual.tileSet.tileheight = 32
    @visual.tileSet.tilewidth = 32
    @visual.tileSet.offset =
      x: 16
      y: 24


  PlayerSkeleton: ->
    @velocity = 250

    @visual.atlas.src = 'gameassets/atlases/nick.png'
    @visual.tileSet.tilesX = 3
    @visual.tileSet.tilesY = 4
    @visual.tileSet.tileheight = 32
    @visual.tileSet.tilewidth = 32
    @visual.tileSet.offset =
      x: 16
      y: 24


  Mario1: ->


  Mario2: ->


  Mario3: ->
    dm = mediator.dialogManager

    @onAction = =>
      data =
        speaker: 'Mario'
        text: 'Hey there. I love being beaten by this Mushroom-Guy. Please, stay there, stare and do nothing.'
        options: 'Okay. Bye.'

      dm.showDialog data, ->
        data.text = 'Are you kidding me? Beat this thing to death. And do it painfully with all your strength. Please.'
        dm.showDialog data


  Gumba: ->
    @hit = 5
    @onAction = =>
      if @hit-- < 0
        @kill()


  Yeti: ->
    @velocity = 200

    @visual.atlas.src = 'gameassets/atlases/yetis.png'

    @visual.tileSet.tilesX = 3
    @visual.tileSet.tilesY = 4
    @visual.tileSet.tileheight = 32
    @visual.tileSet.tilewidth = 32
    @visual.tileSet.offset =
      x: 16
      y: 24
