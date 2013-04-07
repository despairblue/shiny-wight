Entity = require 'models/Entity'
mediator = require 'mediator'

module.exports = class Event extends Entity

  mediator.factory['Event'] = this


  constructor: (x, y, width, height, owningLevel, settings) ->
    # settings.physicsType = 'static'
    # settings.isSensor    = true

    super x, y, width, height, owningLevel, settings


  onTouchBegin: (body, point, impulse) =>
    if @name == 'FirstYeti'
      alert 'da fucking yetis come and get you'
