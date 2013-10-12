Event = require 'entities/Event'
mediator = Chaplin.mediator
story = require 'story/level1'

module.exports = class Level1Prolog extends Event
  constructor: (owningLevel, object) ->
    super owningLevel, object

    @addOneTimeListener 'touchEnd', @_showProlog


  _showProlog: (event) =>
    mediator.dialogManager.showDialog story[8]

    # preload level 3
    mediator.homepageview.loadLevel 'level3'
