Model = require 'models/base/model'
mediator = require "mediator"

module.exports = class MapInitialEntitySpawnManager extends Model

  initialize: ->
    @set 'mediator': (require 'mediator')
    @map = (@get 'mediator').map
    @currMapData = @map.get 'currMapData'


  spawn: () =>

    for layer in @currMapData.layers
      continue if layer.type is 'tilelayer'

      for object in layer.objects
        obj = new mediator.factory[object.name]

        obj.position.x = Math.floor((object.x)/32)
        obj.position.y = Math.floor((object.y)/32)

        obj.load()

        mediator.entities.push(obj)


