mediator = require 'mediator'

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


  level1prolog: ->
    @addListener 'touchEnd', (event) ->
      # execute only once
      @removeListener 'touchEnd', event.listener

      that = @

      data =
        text: 'Once upon a time, all in the golden afternoon, fully leisurely our hero took a walk. The birds they sing, the fire cracks, what a wonderful day. But slowly one by one, its quaint events were hammered out and now the tale is done. Gee. I heard that before...'

      mediator.dialogManager.showDialog data

      # preload level 3
      mediator.homepageview.loadLevel 'level3'


  level1nickTalking: ->
    @addListener 'touchEnd', (event) ->
      # execute only once
      @removeListener 'touchEnd', event.listener

      that = @

      data =
        speaker: 'Nick Human'
        text: 'What a wonderful day. Thus lovely noises, and hey; they get louder when I get closer to  them. God is such a genius.'

      mediator.dialogManager.showDialog data


  level1event1: ->
    @addListener 'touchBegin', (event) ->
      # execute only once
      @removeListener 'touchBegin', event.listener
      that = @

      mediator.homepageview.loadLevel 'level3'

      that.level.addTask ->
        jt = _.clone ss =
          name: 'Yeti'
          type: 'Yeti'
          x: 16*32
          y: 16
          width: 32
          height: 32
          properties: {}

        ss.x = 17*32

        that.jt = that.level.addEntity jt
        that.ss = that.level.addEntity ss

        if mediator.playWithSounds
          mediator.soundManager.stopAll config =
            themeSound: true
            backgroundSounds: true

          mediator.soundManager.playSound that.level.manifest.sounds.sounds[0], 1, true


    @addListener 'touchEnd', (event) ->
      # execute only once
      @removeListener 'touchEnd', event.listener

      that = @
      body = event.arguments[0]
      player = body.GetUserData().ent
      jt = that.jt
      ss = that.ss
      dm = mediator.dialogManager

      dm.hideDialog()

      jt.blockInput().movable.moveDown(150).moveLeft(60)
      jt.scriptable.addTask =>
        data =
          speaker: 'JT'
          text: 'Yo, Snowsome, pathetic human spotted, Yo!'
        dm.showDialog data, (result) ->
          jt.scriptable.addTask ->
            data.speaker = 'Snowsome'
            data.text    = 'Pathetic little you.'
            data.options = 'Run!'

            dm.showDialog data, ->
              ss.movable.moveDown(150).moveLeft(90)
              jt.movable.moveDown(90).moveLeft(30).owner.scriptable.addTask ->

                data.speaker = 'JT'
                data.text = 'Nice bro, you got Him'
                data.options = 'What the...'

                dm.showDialog data, ->
                  jt.scriptable.addTask ->
                    data.text = 'Nice skin, yo.'
                    data.options = 'Uhm... Yeah. Thanks? I guess...'

                    dm.showDialog data, ->
                      jt.scriptable.addTask ->
                        data.text = 'Give it to us'
                        data.options = null

                        dm.showDialog data, ->
                          jt.scriptable.addTask ->
                            data.speaker = 'Snowsome'
                            data.text = 'Yeah, give it to us.'
                            data.options = 'Well... I would prefer not to...'

                            dm.showDialog data, ->
                              # [Black, Smashing Noises, Wilhelms Scream]
                              mediator.configurationManager.configure player, 'PlayerSkeleton'

                              jt.movable.moveRight(80).moveUp(250)
                              ss.movable.moveRight(60).moveUp(250)

                              jt.scriptable.addTask ->
                                data =
                                  speaker: 'Nick Skeleton'
                                  text: 'Seriously? Skin-Robbery? Yetis? I hate those days...'

                                dm.showDialog data, ->
                                  jt.unblockInput().scriptable.addTask -> jt.kill()
                                  ss.kill()


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

    @visual.atlas.src = 'atlases/warrior_m.png'
    @visual.tileSet.tilesX = 3
    @visual.tileSet.tilesY = 4
    @visual.tileSet.tileheight = 32
    @visual.tileSet.tilewidth = 32
    @visual.tileSet.offset =
      x: 16
      y: 24


  PlayerSkeleton: ->
    @velocity = 250

    @visual.atlas.src = 'atlases/nick.png'
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

    @visual.atlas.src = 'atlases/yetis.png'

    @visual.tileSet.tilesX = 3
    @visual.tileSet.tilesY = 4
    @visual.tileSet.tileheight = 32
    @visual.tileSet.tilewidth = 32
    @visual.tileSet.offset =
      x: 16
      y: 24
