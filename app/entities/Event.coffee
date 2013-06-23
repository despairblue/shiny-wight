Entity   = require 'core/Entity'
Scriptable = require 'components/Scriptable'

module.exports = class Event extends Entity
  constructor: (owningLevel, object) ->
    object.properties.physicsType = 'static'
    object.properties.isSensor    = true

    super owningLevel, object

    @scriptable = new Scriptable @
