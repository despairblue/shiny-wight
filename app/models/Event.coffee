Entity   = require 'models/Entity'
mediator = require 'mediator'

module.exports = class Event extends Entity

  mediator.factory['Event'] = this


  constructor: (x, y, width, height, owningLevel, settings) ->
    # settings.physicsType = 'static'
    # settings.isSensor    = true

    super x, y, width, height, owningLevel, settings


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

        @level.addEntity yeti

        mediator.soundManager.stopAll config =
          themeSound: true
          backgroundSounds: true

        mediator.soundManager.playSound @level.manifest.sounds.sounds[0], 1, true
