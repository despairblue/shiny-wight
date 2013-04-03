Entity = require 'models/Entity'
mediator = require 'mediator'

module.exports = class MapChanger extends Entity

  mediator.factory['MapChanger'] = this

  update: =>
    if mediator.player.position.y <= 20 && (480 < mediator.player.position.x < 500)
      mediator.soundManager.stopAll() if mediator.playWithSounds
      mediator.activeLevel = @levelToChangeTo
      @publishEvent 'changeLvl'
