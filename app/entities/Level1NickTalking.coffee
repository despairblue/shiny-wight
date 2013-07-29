Event = require 'entities/Event'
mediator = require 'mediator'
story = require 'story/level1'

module.exports = class Level1NickTalking extends Event
  constructor: (owningLevel, object) ->
    super owningLevel, object

    @addOneTimeListener 'touchEnd', @_nickTalks


  _nickTalks: (event) =>
    mediator.dialogManager.showDialog story[9]
