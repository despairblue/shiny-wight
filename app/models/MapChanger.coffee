Entity = require 'models/Entity'
mediator = require 'mediator'

module.exports = class MapChanger extends Entity

  mediator.factory['Player'] = this

  levelToChangeTo: ""
