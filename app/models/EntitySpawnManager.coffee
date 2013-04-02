Model = require 'models/base/model'
mediator = require "mediator"

module.exports = class EntitySpawnManager extends Model
  # is this really needed?
  #initialize: ->
  #  @set 'mediator': (require 'mediator')


  initialSpawn: () =>
    map = mediator.levels[mediator.activeLevel].mapTiledObject

    for layer in map.layers
      continue if layer.type is 'tilelayer'
      continue if layer.name isnt 'spawnpoints'

      for object in layer.objects
        continue if object.type is ''

        # sanitize constructor attributes
        x = Math.floor object.x
        y = Math.floor object.y
        width = Math.floor object.width
        height = Math.floor object.height


        # get constructor and json config
        Ent = mediator.factory[object.type]
        # TODO: object.name goes to object.tiled_name
        conf = mediator.getActiveLevel().entities[object.name]

        # initialize object with position, size and config
        obj = new Ent(x, y, width, height, conf)

        # TODO: delete?
        obj.position.x = Math.floor object.x
        obj.position.y = Math.floor object.y

        obj.size.x = Math.floor object.width
        obj.size.y = Math.floor object.height

        obj.load()

        mediator.entities.push(obj)
        if object.type == "Player"
          mediator.player = obj


