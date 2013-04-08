Entity   = require 'models/Entity'
mediator = require 'mediator'

module.exports = class Event extends Entity

  mediator.factory['Event'] = this


  constructor: (x, y, width, height, owningLevel, settings) ->
    # settings.physicsType = 'static'
    # settings.isSensor    = true

    super x, y, width, height, owningLevel, settings

    @triggered = false


  onTouchEnd: (body, point, impulse) =>
    if not @triggered
      @triggered = true
      player = body.GetUserData().ent
      that = @
      dm = mediator.dialogManager

      dm.hideDialog()

      @y.blockInput()
      @y.moveDown 150
      ###
      @y.moveLeft 200
      @y.moveRight 10
      @y.moveLeft 10
      @y.moveRight 10
      @y.moveLeft 10
      @y.moveRight 10
      @y.moveLeft 10
      @y.moveRight 10
      @y.moveLeft 10
      @y.moveRight 10
      @y.moveLeft 10
      ###

      pos =
        x: 324
        y: 188

      @y.moveToPosition(pos, 42)
      @y.addTask ->
        data =
          "text": "Nice skin! Give it to me!"
          "options": [
            "Ok!",
            "NO!"]

        dm.showDialog data, (result) ->
          if result is 1
            player.atlas.src = 'atlases/nick.png'
            data =
              "text": "Very good choice!"
              "options": [
                "F... You"
              ]
            dm.showDialog data, ->
              that.unblockInput()
          else if result is 2
            data =
              "text": "Well, ok, what now?"
              "options": [
                "Follow me and everything will be alright!"
              ]
            dm.showDialog data, ->
              that.unblockInput()


  onTouchBegin: (body, point, impulse) =>
    if @name == 'FirstYeti'
      @name = ''
      @level.tasks.push =>
        yeti =
          name: 'Yeti'
          type: 'Yeti'
          x: 16*32
          y: 16
          width: 32
          height: 32
          properties: {
          }

        @y = @level.addEntity yeti

        if mediator.playWithSounds
          mediator.soundManager.stopAll config =
            themeSound: true
            backgroundSounds: true

          mediator.soundManager.playSound @level.manifest.sounds.sounds[0], 1, true
