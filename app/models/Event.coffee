Entity   = require 'core/Entity'
mediator = require 'mediator'

module.exports = class Event extends Entity

  mediator.factory['Event'] = this


  constructor: (owningLevel, object) ->
    object.properties.physicsType = 'static'
    object.properties.isSensor    = true

    @repeat = false

    super owningLevel, object


  onTouch: =>
    super
    @onTouchMethods = [] unless @repeat


  onTouchBegin: =>
    super
    @onTouchBeginMethods = [] unless @repeat


  onTouchEnd: =>
    super
    @onTouchEndMethods = [] unless @repeat
