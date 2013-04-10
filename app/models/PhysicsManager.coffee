Model    = require 'models/base/model'
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

PHYSICS_LOOP    = 1/60


###
Contains a map with all physics bodies.
Can be used by Entities to decide whether they can move to a specific tile.
@note The PhysicsManager expects only only one physics layer to be present
###
module.exports = class PhysicsManager
  world: null

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
  constructor: (@map) ->
    @world = new World(new Vec2(0, 0), false)
    debugDraw = new Box2D.Dynamics.b2DebugDraw()
    dCanvas = document.getElementById('debug-canvas')
    dCtx = dCanvas.getContext '2d'

    @createLevelBorder(@map)

    # initialize debug drawing
    dCanvas.width = window.innerWidth/2 - 100
    dCanvas.height = window.innerHeight - 100
    debugDraw.SetSprite dCtx
    debugDraw.SetDrawScale 0.5
    debugDraw.SetFillAlpha 0.3
    debugDraw.SetLineThickness 1
    debugDraw.SetFlags Box2D.Dynamics.b2DebugDraw.e_shapeBit | Box2D.Dynamics.b2DebugDraw.e_jointBit
    @world.SetDebugDraw debugDraw

    @addBackgroundRigidBodies(@map)


  addBackgroundRigidBodies: () =>
    for layer in @map.layers
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

          x = (tileIndex % @map.width) * @map.tilewidth
          y = Math.floor(tileIndex / @map.width) * @map.tileheight

          pkt = mediator.mapManager.getTilePacket tileID, @map.processedTileSets
          physicsTile = pkt.px / @map.tilewidth
          tileSize = @map.tilewidth

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
  createLevelBorder: () =>
    fixtureDefinition = new FixtureDef()
    fixtureDefinition.shape = new PolygonShape()
    fixtureDefinition.shape.SetAsBox 0, @map.tileheight * @map.height
    mapBorder = new BodyDef()
    mapBorder.type = Body.b2_staticBody
    mapBorder.position.x = 0
    mapBorder.position.y = 0
    body = @registerBody mapBorder, @world
    body.CreateFixture fixtureDefinition

    fixtureDefinition = new FixtureDef()
    fixtureDefinition.shape = new PolygonShape()
    fixtureDefinition.shape.SetAsBox 0, @map.tileheight * @map.height
    mapBorder = new BodyDef()
    mapBorder.type = Body.b2_staticBody
    mapBorder.position.x = @map.tilewidth * @map.width
    mapBorder.position.y = 0
    body = @registerBody mapBorder, @world
    body.CreateFixture fixtureDefinition

    fixtureDefinition = new FixtureDef()
    fixtureDefinition.shape = new PolygonShape()
    fixtureDefinition.shape.SetAsBox @map.tilewidth * @map.width, 0
    mapBorder = new BodyDef()
    mapBorder.type = Body.b2_staticBody
    mapBorder.position.x = 0
    mapBorder.position.y = 0
    body = @registerBody mapBorder, @world
    body.CreateFixture fixtureDefinition

    fixtureDefinition = new FixtureDef()
    fixtureDefinition.shape = new PolygonShape()
    fixtureDefinition.shape.SetAsBox @map.tilewidth * @map.width, 0
    mapBorder = new BodyDef()
    mapBorder.type = Body.b2_staticBody
    mapBorder.position.x = 0
    mapBorder.position.y = @map.tileheight * @map.height
    body = @registerBody mapBorder, @world
    body.CreateFixture fixtureDefinition


  update: =>
    @world.Step PHYSICS_LOOP, 10, 10
    # @world.ClearForces() # not really sure what it's for and if we need it

  addContactListener: (callbacks) =>
    listener = new Box2D.Dynamics.b2ContactListener()

    if callbacks.BeginContact
      listener.BeginContact = (contact) ->
        callbacks.BeginContact contact.GetFixtureA().GetBody(), contact.GetFixtureB().GetBody()
    if callbacks.EndContact
      listener.EndContact = (contact) ->
        callbacks.EndContact contact.GetFixtureA().GetBody(), contact.GetFixtureB().GetBody()
    if callbacks.PostSolve
      listener.PostSolve = (contact, impulse) ->
        callbacks.PostSolve contact.GetFixtureA().GetBody(), contact.GetFixtureB().GetBody(), impulse.normalImpulses[0]

    @world.SetContactListener listener


  registerBody: (bodyDef) =>
    body = @world.CreateBody bodyDef


  addBody: (entityDef) =>
    bodyDef = new BodyDef()

    halfWidth = Math.floor entityDef.width / 2
    halfHeight = Math.floor entityDef.height / 2

    if entityDef.type == 'static'
      bodyDef.type = Body.b2_staticBody
    else
      bodyDef.type = Body.b2_dynamicBody

    bodyDef.position.x = entityDef.x + halfWidth
    bodyDef.position.y = entityDef.y + halfHeight

    bodyDef.userData = entityDef.userData if entityDef.userData

    body = @registerBody bodyDef
    fixtureDefinition = new FixtureDef()

    fixtureDefinition.isSensor = true if entityDef.isSensor

    if entityDef.ellipse
      fixtureDefinition.shape = new CircleShape()
      fixtureDefinition.shape.SetRadius halfWidth
    else
      fixtureDefinition.shape = new PolygonShape()
      fixtureDefinition.shape.SetAsBox halfWidth, halfHeight

    body.CreateFixture fixtureDefinition

    body

  removeBody: (obj) =>
    @world.DestroyBody obj


