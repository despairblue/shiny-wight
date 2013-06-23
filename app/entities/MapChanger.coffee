Entity = require 'core/Entity'
mediator = require 'mediator'

module.exports = class MapChanger extends Entity
  constructor: (owningLevel, object) ->
    object.properties.physicsType = 'static'
    object.properties.isSensor    = true

    super owningLevel, object


  onTouchBegin: (body, point, impulse) =>
    if body.GetUserData().ent.name in ['Player', 'PlayerSkeleton']
      if mediator.playWithSounds
        mediator.soundManager.stopAll config =
          sounds: true
          backgroundSounds: true
      mediator.nextLevel = @levelToChangeTo
      mediator.publish 'changeLvl'
