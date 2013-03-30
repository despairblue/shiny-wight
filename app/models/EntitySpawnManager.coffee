Model = require 'models/base/model'
mediator = require "mediator"

module.exports = class EntitySpawnManager extends Model
  # is this really needed?
  #initialize: ->
  #  @set 'mediator': (require 'mediator')


  initialSpawn: () =>
    map = mediator.levels[mediator.activeLevel].gMap
    currMapData = map.get 'currMapData'

    for layer in currMapData.layers
      continue if layer.type is 'tilelayer'

      for object in layer.objects
        obj = new mediator.factory[object.type]

        obj.position.x = Math.floor object.x
        obj.position.y = Math.floor object.y

        obj.size.x = Math.floor object.width
        obj.size.y = Math.floor object.height

        obj.load()

        mediator.entities.push(obj)
        if object.type == "Player"
          mediator.player = obj


