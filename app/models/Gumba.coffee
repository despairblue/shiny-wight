Entity = require 'core/Entity'
Visual = require 'core/components/Visual'
mediator = require 'mediator'

module.exports = class Gumba extends Entity
  # register entity
  mediator.factory['Gumba'] = this


  constructor: (owningLevel, object) ->
    # settings.ellipse = true
    object.properties.physicsType = 'static'

    super owningLevel, object
    @visual = v = new Visual @

    do (v) ->
      v.atlas.src = 'atlases/gumba.png'

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
