Model = require 'models/base/model'
mediator = require 'mediator'

###
Contains a map with all physics bodies.
Can be used by Entities to decide whether they can move to a specific tile.
@note The PhysicsManager expects only only one physics layer to be present
###
module.exports = class PhysicsManager extends Model
  ###
  @private
  Initializes an instance
  ###
  initialize: ->
    super
    mediator.physicsManager = @

    @subscribeEvent 'map:rendered', =>
      @setup()

  ###
  Look for the physics layer inside the map.
  Fills in a local representation of it.
  @note The PhysicsManager expects only only one physics layer to be present
  ###
  setup: =>
    map = mediator.map
    currMapData = map.currMapData

    @physicsMap = []
    for x in [0..map.numXTiles - 1]
      @physicsMap[x] = for y in [0..map.numYTiles - 1]
        false

    for layer in currMapData.layers
      continue if layer.name isnt 'physics'

      for tileID, tileIndex in layer.data
        continue if tileID is 0

        x = (tileIndex % map.numXTiles)
        y = Math.floor(tileIndex / map.numXTiles)

        @physicsMap[x][y] = 'background'

      # there should only be one physics layer
      break;

  ###
  Checks if the position is free
  @param [Integer] x the x value of the position
  @param [Integer] y the y value of the position
  ###
  canIMoveThere: (x, y) =>
    if @physicsMap[x][y] is false
      return true
    else
      return false

