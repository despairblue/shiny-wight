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
    @onTouchEndMethods.push (body, point, impulse) ->
      that = @

      data =
        text: 'Once upon a time, all in the golden afternoon, fully leisurely our hero took a walk. The birds they sing, the fire cracks, what a wonderful day. But slowly one by one, its quaint events were hammered out and now the tale is done. Gee. I heard that before...'
        options: 'Ok'

      mediator.dialogManager.showDialog data

      # preload level 3
      mediator.homepageview.loadLevel 'level3'


  level1nickTalking: ->
    @onTouchEndMethods.push (body, point, impulse) ->
      that = @

      data =
        speaker: 'Nick Human'
        text: 'What a wonderful day. Thus lovely noises, and hey; they get louder when I get closer to  them. God is such a genius.'
        options: 'Yeah'

      mediator.dialogManager.showDialog data


  level1event1: ->
    @onTouchBeginMethods.push (body, point, impulse) ->
      that = @

      mediator.homepageview.loadLevel 'level3'

      that.level.tasks.push ->
        yeti =
          name: 'Yeti'
          type: 'Yeti'
          x: 16*32
          y: 16
          width: 32
          height: 32
          properties: {
          }

        that.y = y = that.level.addEntity yeti

        if mediator.playWithSounds
          mediator.soundManager.stopAll config =
            themeSound: true
            backgroundSounds: true

          mediator.soundManager.playSound that.level.manifest.sounds.sounds[0], 1, true

    @onTouchEndMethods.push (body, point, impulse) ->
      that = @
      player = body.GetUserData().ent
      dm = mediator.dialogManager

      dm.hideDialog()

      that.y.blockInput()
      that.y.moveDown 150
      that.y.moveLeft 60
      that.y.addTask =>
        data =
          "text": "SnowSam: \"Look Jt! A fresh human over there!\""
          "options": [
            "Next"]
        dm.showDialog data, (result) ->
          if result is 1
            that.y.moveDown 30
            that.y.addTask ->
              data =
                "text": "Nice skin! Give it to me!"
                "options": [
                  "Ok!",
                  "NO!"]

              dm.showDialog data, (result) ->
                if result is 1
                  # player.atlas.src = 'atlases/nick.png'
                  mediator.configurationManager.configure player, 'PlayerSkeleton'
                  data =
                    "text": "Very good choice!"
                    "options": [
                      "F... You"
                    ]
                  dm.showDialog data, ->
                    that.y.moveDown 200
                    that.y.moveRight 30
                    that.y.moveDown 50

                    that.y.unblockInput()

                    that.y.addTask ->
                      that.y.kill()

                      true

                else if result is 2
                  data =
                    "text": "Well, ok, what now?"
                    "options": [
                      "Follow me and everything will be alright!"
                    ]
                  dm.showDialog data, ->
                    # that.y.moveToPosition(player.position, 30)
                    data =
                      text: "No following is broken! Fix it first!"
                      options: ["I'll do this right now!"]

                    dm.showDialog data, ->
                      that.y.unblockInput()


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

    @atlas.src = 'atlases/warrior_m.png'
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

    @atlas.src = 'atlases/mario.png'

    @tileSet.tilesX = 3
    @tileSet.tilesY = 4
    @tileSet.tileheight = 32
    @tileSet.tilewidth = 32
    @tileSet.offset =
      x: 14
      y: 24


  Yeti: ->
    @velocity = 200

    @atlas.src = 'atlases/yetis.png'

    @tileSet.tilesX = 3
    @tileSet.tilesY = 4
    @tileSet.tileheight = 32
    @tileSet.tilewidth = 32
    @tileSet.offset =
      x: 16
      y: 24
