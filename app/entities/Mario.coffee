Entity = require 'core/Entity'
Visual = require 'components/Visual'
mediator = Chaplin.mediator

module.exports = class Mario extends Entity
  constructor: (owningLevel, object) ->
    # settings.ellipse = true
    object.properties.physicsType = 'static'

    super owningLevel, object
    @visual = v = new Visual @

    do (v) ->
      v.atlas.src = 'gameassets/atlases/mario.png'

      v.spriteState.viewDirection = 2

      v.tileSet.tilesX = 3
      v.tileSet.tilesY = 4
      v.tileSet.tileheight = 32
      v.tileSet.tilewidth = 32
      v.tileSet.offset =
        x: 14
        y: 24


  update: =>
    super
