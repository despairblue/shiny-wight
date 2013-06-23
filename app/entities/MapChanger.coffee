Event = require 'entities/Event'
mediator = require 'mediator'

module.exports = class MapChanger extends Event
  constructor: (owningLevel, object) ->
    super owningLevel, object


  onTouchBegin: (body, point, impulse) =>
    if body.GetUserData().ent.name in ['Player', 'PlayerSkeleton']
      if mediator.playWithSounds
        mediator.soundManager.stopAll config =
          sounds: true
          backgroundSounds: true
      mediator.nextLevel = @levelToChangeTo
      mediator.publish 'changeLvl'
