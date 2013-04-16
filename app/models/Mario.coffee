Entity = require 'core/Entity'
Visual = require 'core/mixins/Visual'
mediator = require 'mediator'

module.exports = class Mario extends Entity
  @include Visual
  # register entity
  mediator.factory['Mario'] = this


  constructor: (owningLevel, object) ->
    # settings.ellipse = true
    object.properties.physicsType = 'static'

    @_visual_setUp('atlases/mario.png')

    super owningLevel, object

    @_visual_init()

    @spriteState.viewDirection = 2

    @tileSet.tilesX = 3
    @tileSet.tilesY = 4
    @tileSet.tileheight = 32
    @tileSet.tilewidth = 32
    @tileSet.offset =
      x: 14
      y: 24


  update: =>
    super
