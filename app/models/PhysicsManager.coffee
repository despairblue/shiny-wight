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
    map = mediator.levels[mediator.activeLevel].mapTiledObject
    @world = new World(new Vec2(0, 0), false)
    debugDraw = new Box2D.Dynamics.b2DebugDraw()
    dCanvas = document.getElementById('debug-canvas')
    dCtx = dCanvas.getContext '2d'

    @createLevelBorder(map)

    # initialize debugging canvas
    # document.getElementById('debug-container').appendChild dCanvas

    dCanvas.width = window.innerWidth/2 - 100
    dCanvas.height = window.innerHeight
    debugDraw.SetSprite dCtx
    debugDraw.SetDrawScale 0.5
    debugDraw.SetFillAlpha 0.3
    debugDraw.SetLineThickness 1
    debugDraw.SetFlags Box2D.Dynamics.b2DebugDraw.e_shapeBit | Box2D.Dynamics.b2DebugDraw.e_jointBit
    @world.SetDebugDraw debugDraw

    @addBackgroundRigidBodies(map)

  addBackgroundRigidBodies: (map) =>
    for layer in map.layers
      continue if layer.name isnt 'physics'

      # create polygons
      if layer.type is 'objectgroup'
        for object in layer.objects
          if object.polygon
            vec2Array = (new Vec2(vec2.x, vec2.y) for vec2 in object.polygon)
            @createStaticBodyWithPolygon vec2Array, object.x, object.y
          else
            @createStaticBodyWithBox object.x, object.y, object.width, object.height

      # create boxes and triangles
      else if layer.type is 'tilelayer'
        # map = mediator.levels[mediator.activeLevel].gMap

        for tileID, tileIndex in layer.data
          continue if tileID is 0

          x = (tileIndex % map.width) * map.tilewidth
          y = Math.floor(tileIndex / map.width) * map.tileheight

          pkt = mediator.mapManager.getTilePacket tileID, mediator.getActiveLevel().tileSets
          physicsTile = pkt.px / map.tilewidth
          tileSize = map.tilewidth

          if physicsTile is 0
            @createStaticBodyWithBox x, y, tileSize, tileSize
          else if physicsTile is 1
            vec2Array = [new Vec2(0, tileSize), new Vec2(tileSize, 0), new Vec2(tileSize, tileSize)]
            @createStaticBodyWithPolygon vec2Array, x, y
          else if physicsTile is 2
            vec2Array = [new Vec2(0, 0), new Vec2(tileSize, tileSize), new Vec2(0, tileSize)]
            @createStaticBodyWithPolygon vec2Array, x, y
          else if physicsTile is 3
            vec2Array = [new Vec2(0, 0), new Vec2(tileSize, 0), new Vec2(tileSize, tileSize)]
            @createStaticBodyWithPolygon vec2Array, x, y
          else if physicsTile is 4
            vec2Array = [new Vec2(0, 0), new Vec2(tileSize, 0), new Vec2(0, tileSize)]
            @createStaticBodyWithPolygon vec2Array, x, y






  createStaticBodyWithBox: (x, y, w, h) =>
    fixtureDefinition = new FixtureDef()
    fixtureDefinition.shape = new PolygonShape()
    fixtureDefinition.shape.SetAsBox w/2, h/2
    bgRigidBody = new BodyDef()
    bgRigidBody.type = Body.b2_staticBody
    bgRigidBody.position.x = x + w/2
    bgRigidBody.position.y = y + h/2
    body = @registerBody bgRigidBody
    body.CreateFixture fixtureDefinition

  createStaticBodyWithPolygon: (vec2Array, x, y) =>
    fixtureDefinition = new FixtureDef()
    fixtureDefinition.shape = new PolygonShape()
    fixtureDefinition.shape.SetAsArray vec2Array, vec2Array.length
    bgRigidBody = new BodyDef()
    bgRigidBody.type = Body.b2_staticBody
    bgRigidBody.position.x = x
    bgRigidBody.position.y = y
    body = @registerBody bgRigidBody
    body.CreateFixture fixtureDefinition

  ###
  @todo movo to TiledMap
  ###
  createLevelBorder: (map) =>
    fixtureDefinition = new FixtureDef()
    fixtureDefinition.shape = new PolygonShape()
    fixtureDefinition.shape.SetAsBox 0, map.tileheight * map.height
    mapBorder = new BodyDef()
    mapBorder.type = Body.b2_staticBody
    mapBorder.position.x = 0
    mapBorder.position.y = 0
    body = @registerBody mapBorder
    body.CreateFixture fixtureDefinition

    fixtureDefinition = new FixtureDef()
    fixtureDefinition.shape = new PolygonShape()
    fixtureDefinition.shape.SetAsBox 0, map.tileheight * map.height
    mapBorder = new BodyDef()
    mapBorder.type = Body.b2_staticBody
    mapBorder.position.x = map.tilewidth * map.width
    mapBorder.position.y = 0
    body = @registerBody mapBorder
    body.CreateFixture fixtureDefinition

    fixtureDefinition = new FixtureDef()
    fixtureDefinition.shape = new PolygonShape()
    fixtureDefinition.shape.SetAsBox map.tilewidth * map.width, 0
    mapBorder = new BodyDef()
    mapBorder.type = Body.b2_staticBody
    mapBorder.position.x = 0
    mapBorder.position.y = 0
    body = @registerBody mapBorder
    body.CreateFixture fixtureDefinition

    fixtureDefinition = new FixtureDef()
    fixtureDefinition.shape = new PolygonShape()
    fixtureDefinition.shape.SetAsBox map.tilewidth * map.width, 0
    mapBorder = new BodyDef()
    mapBorder.type = Body.b2_staticBody
    mapBorder.position.x = 0
    mapBorder.position.y = map.tileheight * map.height
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
      bodyDef.type = Body.b2_staticBody
    else
      bodyDef.type = Body.b2_dynamicBody

    bodyDef.position.x = entityDef.x
    bodyDef.position.y = entityDef.y

    bodyDef.userData = entityDef.userData if entityDef.userData

    body = @registerBody bodyDef
    fixtureDefinition = new FixtureDef()

    # TODO: remove hard coding
    if id is 'Player'
      fixtureDefinition.shape = new CircleShape()
      fixtureDefinition.shape.SetRadius entityDef.halfWidth
    else
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

