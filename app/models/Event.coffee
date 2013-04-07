Entity   = require 'models/Entity'
mediator = require 'mediator'

module.exports = class Event extends Entity

  mediator.factory['Event'] = this


  constructor: (x, y, width, height, owningLevel, settings) ->
    # settings.physicsType = 'static'
    # settings.isSensor    = true

    super x, y, width, height, owningLevel, settings


  onTouchEnd: (body, point, impulse) =>
    $('#dialog').empty()
    @y.moveDown 150
    @y.moveLeft 200
    @y.moveRight 10
    @y.moveLeft 10
    @y.moveRight 10
    @y.moveLeft 10
    @y.moveRight 10
    @y.moveLeft 10
    @y.moveRight 10
    @y.moveLeft 10
    @y.moveRight 10
    @y.moveLeft 10


  onTouchBegin: (body, point, impulse) =>
    source = document.getElementById 'some-template'
    template = Handlebars.compile(source.innerText)

    data =
      "text": "Can I help you?"
      "options": [
        {"text": "Can I go into your cellar, please.", "id":1},
        {"text": "Nothing. Bye", "id":2},
        {"text": "Nice skin. Can i have it?"}
        {"text": "eine vierte option hinzufuegen"}]

    result = $ template(data)

    $('#dialog').append result

    if @name == 'FirstYeti'
      @name = ''
      @level.tasks.push =>
        yeti =
          name: 'Yeti'
          type: 'Yeti'
          x: 16*32
          y: 16
          width: 32
          height: 32
          properties: {
          }

        @y = @level.addEntity yeti

        if mediator.playWithSounds
          mediator.soundManager.stopAll config =
            themeSound: true
            backgroundSounds: true

          mediator.soundManager.playSound @level.manifest.sounds.sounds[0], 1, true
