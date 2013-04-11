Entity   = require 'core/Entity'
mediator = require 'mediator'

module.exports = class Event extends Entity

  mediator.factory['Event'] = this


  constructor: (x, y, width, height, owningLevel, settings) ->
    # settings.physicsType = 'static'
    # settings.isSensor    = true

    super x, y, width, height, owningLevel, settings

    @triggered = false
