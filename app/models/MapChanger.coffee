Entity = require 'models/Entity'
mediator = require 'mediator'

module.exports = class MapChanger extends Entity

  mediator.factory['MapChanger'] = this

  levelToChangeTo: ""


  constructor: (x, y, width, height, owningLevel, settings) ->
    settings.physicsType = 'static'
    settings.isSensor    = true

    super x, y, width, height, owningLevel, settings
    levelToChangeTo = "pisse"




  onTouchBegin: (body, point, impulse) =>
    mediator.soundManager.stopAll() if mediator.playWithSounds
    mediator.activeLevel = @levelToChangeTo
    @publishEvent 'changeLvl'
