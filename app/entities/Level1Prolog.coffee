Event = require 'entities/Event'
mediator = require 'mediator'

module.exports = class Level1Prolog extends Event
  constructor: (owningLevel, object) ->
    super owningLevel, object

    @addOneTimeListener 'touchEnd', @_showProlog


  _showProlog: (event) =>
    data =
      text: 'Once upon a time, all in the golden afternoon, fully leisurely our hero took a walk. The birds they sing, the fire cracks, what a wonderful day. But slowly one by one, its quaint events were hammered out and now the tale is done. Gee. I heard that before...'

    mediator.dialogManager.showDialog data

    # preload level 3
    mediator.homepageview.loadLevel 'level3'
