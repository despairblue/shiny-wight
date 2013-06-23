Event = require 'entities/Event'

module.exports = class Level1NickTalking extends Event
  constructor: (owningLevel, object) ->
    super owningLevel, object

    @addOneTimeListener 'touchEnd', @_nickTalks


  _nickTalks: (event) =>
    data =
      speaker: 'Nick Human'
      text: 'What a wonderful day. Thus lovely noises, and hey; they get louder when I get closer to  them. God is such a genius.'

    mediator.dialogManager.showDialog data
