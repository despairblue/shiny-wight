Entity = require 'models/Entity'
mediator = require 'mediator'

module.exports = class MapChanger extends Entity

  mediator.factory['MapChanger'] = this

  entityDef:
    type: "static"
    x: 0
    y: 0
    halfWidth: 16
    halfHeight: 1
    userData:
      ent: null

  levelToChangeTo: ""


  constructor: (x, y, width, height, owningLevel, settings) ->

    super x, y, width, height, owningLevel, settings
    levelToChangeTo = "pisse"




  onTouchBegin: (body, point, impulse) =>
    mediator.soundManager.stopAll() if mediator.playWithSounds
    mediator.levels[mediator.activeLevel] = null
    mediator.activeLevel = @levelToChangeTo
    @publishEvent 'changeLvl'
