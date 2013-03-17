Model = require 'models/base/model'
mediator = require "models/mediator"

module.exports = class MapInitialEntitySpawnMagager extends Model

  map = (@get 'mediator').map
  layers = (@map.get 'currMapData').layers

  render: () =>

    for layer in @layers
      continue if @layer.type is 'tilelayer'

      for object in @layers.Objectgroup.Objects
        obj = new mediator.factory[object.name]
        obj.position.x = Math.floor(object.pos.x/32)
        obj.position.y = Math.floor(object.pos.y/32)

        mediator.entities.push(obj)


