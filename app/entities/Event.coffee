Entity   = require 'core/Entity'
mediator = require 'mediator'

module.exports = class Event extends Entity
  constructor: (owningLevel, object) ->
    object.properties.physicsType = 'static'
    object.properties.isSensor    = true

    @repeat = false

    super owningLevel, object


  onTouch: =>
    super


  onTouchBegin: =>
    super


  onTouchEnd: =>
    super
