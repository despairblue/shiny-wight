Model = require 'models/base/model'
mediator = require 'mediator'

Vec2             = Box2D.Common.Math.b2Vec2
BodyDef          = Box2D.Dynamics.b2BodyDef
Body             = Box2D.Dynamics.b2Body
FixtureDef       = Box2D.Dynamics.b2FixtureDef
Fixture          = Box2D.Dynamics.b2Fixture
World            = Box2D.Dynamics.b2World
MassData         = Box2D.Collision.Shapes.b2MassData
PolygonShape     = Box2D.Collision.Shapes.b2PolygonShape
CircleShape      = Box2D.Collision.Shapes.b2CircleShape
DebugDraw        = Box2D.Dynamics.b2DebugDraw
RevoluteJointDef = Box2D.Dynamics.Joints.b2RevoluteJointDef

###
Contains a map with all physics bodies.
Can be used by Entities to decide whether they can move to a specific tile.
@note The PhysicsManager expects only only one physics layer to be present
###
module.exports = class PhysicsManager extends Model
  world: null
  physicsLoopHZ: 1/25

  Vec2: Box2D.Common.Math.b2Vec2
  BodyDef: Box2D.Dynamics.b2BodyDef
  Body: Box2D.Dynamics.b2Body
  FixtureDef: Box2D.Dynamics.b2FixtureDef
  Fixture: Box2D.Dynamics.b2Fixture
  World: Box2D.Dynamics.b2World
  MassData: Box2D.Collision.Shapes.b2MassData
  PolygonShape: Box2D.Collision.Shapes.b2PolygonShape
  CircleShape: Box2D.Collision.Shapes.b2CircleShape
  DebugDraw: Box2D.Dynamics.b2DebugDraw
  RevoluteJointDef: Box2D.Dynamics.Joints.b2RevoluteJointDef

  ###
  @private
  Initializes an instance
  ###
  initialize: ->
    super
    mediator.physicsManager = @
    ###
    @subscribeEvent 'map:rendered', =>
      @setup()
    ###

  ###
  Look for the physics layer inside the map.
  Fills in a local representation of it.
  @note The PhysicsManager expects only only one physics layer to be present
  ###
  setup: =>
    @world = new World(new Vec2(0, 0), false)
    debugDraw = new Box2D.Dynamics.b2DebugDraw()
    dCanvas = document.createElement 'canvas'
    dCtx = dCanvas.getContext '2d'

    @createLevelBorder()

    # initialize debugging canvas
    document.getElementById('debug-container').appendChild dCanvas
    dCanvas.width = window.innerWidth/2 - 100
    dCanvas.height = window.innerHeight
    debugDraw.SetSprite dCtx
    debugDraw.SetDrawScale 0.5
    debugDraw.SetFillAlpha 0.3
    debugDraw.SetLineThickness 1
    debugDraw.SetFlags Box2D.Dynamics.b2DebugDraw.e_shapeBit | Box2D.Dynamics.b2DebugDraw.e_jointBit
    @world.SetDebugDraw debugDraw


    # TODO: read background boundaries from map, should actually be done im map
    # fixtureDefinition.shape.SetAsArray [
    #   new Vec2(-1, 0),
    #   new Vec2(0, 0),
    #   new Vec2(0, mediator.map.pixelSize.y),
    #   new Vec2(-1, mediator.map.pixelSize.y)], 4

    # map = mediator.levels[mediator.activeLevel].gMap
    # currMapData = map.currMapData

    # mediator.levels[mediator.activeLevel].physicsMap = []
    # for x in [0..map.numXTiles - 1]
    #   mediator.levels[mediator.activeLevel].physicsMap[x] = for y in [0..map.numYTiles - 1]
    #     false

    # for layer in currMapData.layers
    #   continue if layer.name isnt 'physics'

    #   for tileID, tileIndex in layer.data
    #     continue if tileID is 0

    #     x = (tileIndex % map.numXTiles)
    #     y = Math.floor(tileIndex / map.numXTiles)

    #     mediator.levels[mediator.activeLevel].physicsMap[x][y] = 'background'
    #   # there should only be one physics layer
    #   break

  ###
  @todo should actually go to TILEDMap.coffee
  ###
  createLevelBorder: =>
    map = mediator.levels[mediator.activeLevel].gMap

    fixtureDefinition = new FixtureDef()
    fixtureDefinition.shape = new PolygonShape()
    fixtureDefinition.shape.SetAsBox 0, map.pixelSize.y
    mapBorder = new BodyDef()
    mapBorder.type = Body.b2_staticBody
    mapBorder.position.x = 0
    mapBorder.position.y = 0
    body = @registerBody mapBorder
    body.CreateFixture fixtureDefinition

    fixtureDefinition = new FixtureDef()
    fixtureDefinition.shape = new PolygonShape()
    fixtureDefinition.shape.SetAsBox 0, map.pixelSize.y
    mapBorder = new BodyDef()
    mapBorder.type = Body.b2_staticBody
    mapBorder.position.x = map.pixelSize.x
    mapBorder.position.y = 0
    body = @registerBody mapBorder
    body.CreateFixture fixtureDefinition

    fixtureDefinition = new FixtureDef()
    fixtureDefinition.shape = new PolygonShape()
    fixtureDefinition.shape.SetAsBox map.pixelSize.x, 0
    mapBorder = new BodyDef()
    mapBorder.type = Body.b2_staticBody
    mapBorder.position.x = 0
    mapBorder.position.y = 0
    body = @registerBody mapBorder
    body.CreateFixture fixtureDefinition

    fixtureDefinition = new FixtureDef()
    fixtureDefinition.shape = new PolygonShape()
    fixtureDefinition.shape.SetAsBox map.pixelSize.x, 0
    mapBorder = new BodyDef()
    mapBorder.type = Body.b2_staticBody
    mapBorder.position.x = 0
    mapBorder.position.y = map.pixelSize.y
    body = @registerBody mapBorder
    body.CreateFixture fixtureDefinition


  update: =>
    start = Date.now()

    @world.Step @physicsLoopHZ, 10, 10
    @world.DrawDebugData() if debug
    # @world.ClearForces() # not really sure what it's for and if we need it

    Date.now() - start

  addContactListener: (callbacks) =>
    listener = new Box2D.Dynamics.b2ContactListener()

    if callbacks.PostSolve
      listener.PostSolve = (contact, impulse) =>
        callbacks.PostSolve contact.GetFixtureA().GetBody(), contact.GetFixtureB.GetBody, impulse.normalImpulses[0]

    @world.SetContactListener listener

  registerBody: (bodyDef) =>
    body = @world.CreateBody bodyDef

  addBody: (entityDef) =>
    bodyDef = new BodyDef()

    id = entityDef.id

    if entityDef.type == 'static'
      bodyDef.type = Body.b2_staticBody;
    else
      bodyDef.type = Body.b2_dynamicBody

    bodyDef.position.x = entityDef.x
    bodyDef.position.y = entityDef.y

    bodyDef.userData = entityDef.userData if entityDef.userData

    body = @registerBody bodyDef
    fixtureDefinition = new FixtureDef()

    fixtureDefinition.shape = new PolygonShape()
    fixtureDefinition.shape.SetAsBox entityDef.halfWidth, entityDef.halfHeight
    body.CreateFixture fixtureDefinition

    body

  removeBody: (obj) =>
    @world.DestroyBody obj

  # ###
  # Checks if the position is free
  # @param [Integer] x the x value of the position
  # @param [Integer] y the y value of the position
  # ###
  # canIMoveThere: (x, y) =>
  #   # TODO: just a temporary fix, use box2d later
  #   x = Math.floor x/32
  #   y = Math.floor y/32
  #   if mediator.levels[mediator.activeLevel].physicsMap[x][y] is false
  #     return true

