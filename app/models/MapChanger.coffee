Entity = require 'core/Entity'
mediator = require 'mediator'

module.exports = class MapChanger extends Entity

  mediator.factory['MapChanger'] = this


  constructor: (x, y, width, height, owningLevel, settings) ->
    settings.physicsType = 'static'
    settings.isSensor    = true

    super x, y, width, height, owningLevel, settings


  onTouchBegin: (body, point, impulse) =>
    if body.GetUserData().ent.name in ['Player', 'PlayerSkeleton']
      if mediator.playWithSounds
        mediator.soundManager.stopAll config =
          sounds: true
          backgroundSounds: true
      mediator.nextLevel = @levelToChangeTo
      mediator.publish 'changeLvl'
