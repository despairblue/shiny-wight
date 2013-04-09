Model = require 'models/base/model'
mediator = require 'mediator'

###
Base class for all entities

@example How to subclass Entity
  module.exports = class VisibleEntity extends Entity
    onAction: (object): ->
      # do something
###
module.exports = class Entity extends Model

  ###
  @property [Object] The entity's position in pixels
  @option position [Integer] x y coordinate
  ###
  position:
    x: 0
    y: 0

  ###
  @property [Object] The entity's size
  ###
  size:
    x: 0
    y: 0

  ###
  @property [Integer]
  What sprite to draw
  ###
  animationStep: 0

  ###
  @property [Integer]
  Entity' velocity
  Standart velocity = 10
  ###
  velocity: 400

  entityDef:
    ellipse: false
    type: "dynamic"
    x: 0
    y: 0
    width: 0
    height: 0
    userData:
      ent: null

  ###
  @property [Integer]
  In what direction the entity looks

      0:up
      1:right
      2:down
      3:left
  ###
  viewDirection: 0

  constructor: (x, y, width, height, owningLevel, settings) ->
    super

    @[prop] = content for prop, content of settings

    @level = owningLevel

    @position =
      x: x
      y: y

    @oldPosition =
      x: 0
      y: 0

    # TODO the fewest entities need this block (only player and NPCs/Monsters, in my humble opinion)
    @maxDistance = 0
    @positionToMoveTo = null
    @onFollow = false
    @positionCheckTimer = Date.now()
    @counter = 0
    @tryOtherDirection = false

    @size.x = width

    @size =
      x: width
      y: height

    @entityDef =
      ellipse: false
      type: "dynamic"
      x: 0
      y: 0
      width: 0
      height: 0
      userData:
        ent: null

    @tasks = []
    @moving =
      up: false
      down: false
      right: false
      left: false

    @entityDef.x = @position.x
    @entityDef.y = @position.y
    @entityDef.width = width
    @entityDef.height = height
    @entityDef.userData.ent = @
    @entityDef.ellipse = true if settings.ellipse
    @entityDef.type = settings.physicsType if settings.physicsType
    @entityDef.isSensor = true if settings.isSensor

    @physBody = @level.physicsManager.addBody @entityDef, @level.b2World
    @physBody.SetLinearVelocity(new @level.physicsManager.Vec2(0, 0))



  ###
  @private
  Initializes the new Entity.
  Will try to get the map from the mediator.
  @note Make sure to call `TILEDMap.load(path)` before instantiating any Entities.
  ###
  initialize: ->
    @map = mediator.levels[mediator.activeLevel].gMap

  # TODO: reimplement...
  # ###
  # @private
  # @param [Integer] vd
  #   the view direction. Can be one of 0, 1, 2 or 3.
  # @see [Entity#viewDirection]
  # Updates the animationStep counter and viewDirection.
  # If the entity goes into the same direction, only update animationStep
  # If not it will reset the animationStep counter and update the viewDirection
  # ###
  # updateViewAndAnimation: (vd) =>
  #   if @viewDirection != vd
  #     @animationStep = 1
  #     @viewDirection = vd
  #   else
  #     @animationStep++
  #     if mediator.PlayWithSounds
  #       @onPositionChange()

  ###
  Is called if the Player stands in front of this Entity and want's to interact with it.
  @param [Object] player
    The Player.
  ###
  onAction: (player) =>
    # perform an <Object> specific action


  ###
  Is called when the Entity moved
  @note removed publish event 'anyEntityhere:moved' for much(!) better performance
  ###
  onPositionChange: =>
    # method to be overloaded


  load: =>
    # ..


  render: =>
    # ..


  onTouch: (body, point, impulse) =>
    # ...


  onTouchBegin: (body, point) =>
    # ...


  onTouchEnd: (body, point) =>
    # ...


  makeMeStatic: () =>
    @oldVelocity = _.clone @physBody.GetLinearVelocity()
    @physBody.SetType Box2D.Dynamics.b2Body.b2_staticBody


  makeMeDynamic: () =>
    @physBody.SetType Box2D.Dynamics.b2Body.b2_dynamicBody
    @physBody.SetAwake true
    @physBody.SetLinearVelocity @oldVelocity


  moveDown: (pixel) =>
    console.error 'argument must be an positive integer' if pixel < 0
    @tasks.push () ->
      @targetPos =
        x: @position.x
        y: @position.y + pixel
      @moving.down = true
      @spriteState.moving = true
      @spriteState.viewDirection = 2


  moveUp: (pixel) =>
    console.error 'argument must be an positive integer' if pixel < 0
    @tasks.push () ->
      @targetPos =
        x: @position.x
        y: @position.y - pixel
      @moving.up = true
      @spriteState.moving = true
      @spriteState.viewDirection = 0


  moveRight: (pixel) =>
    console.error 'argument must be an positive integer' if pixel < 0
    @tasks.push () ->
      @targetPos =
        x: @position.x + pixel
        y: @position.y
      @moving.right = true
      @spriteState.moving = true
      @spriteState.viewDirection = 1


  moveLeft: (pixel) =>
    console.error 'argument must be an positive integer' if pixel < 0
    @tasks.push (context) ->
      @targetPos =
        x: @position.x - pixel
        y: @position.y
      @moving.left = true
      @spriteState.moving = true
      @spriteState.viewDirection = 3


  stopMovement: (pixel) =>
    @physBody.SetLinearVelocity(new @level.physicsManager.Vec2(0, 0))
    @moving.down        = false
    @moving.up          = false
    @moving.left        = false
    @moving.right       = false
    @spriteState.moving = false


  ###
  Is called each tick/frame.
  ###
  update: =>

    checkPosition = false

    # TODO not all entities need the following block.. actually the fewest entities need this
    # so move it into a subclass to increase performance
    @counter +=1
    if @counter % 10 == 0
      @counter = 1
      if Date.now() - @positionCheckTimer > 2000
        checkPosition = true
        @positionCheckTimer == Date.now()


    @position.x = @physBody.GetPosition().x if @physBody.GetPosition().x?
    @position.y = @physBody.GetPosition().y if @physBody.GetPosition().y?

    if @moving.down
      if @position.y > @targetPos.y
        @stopMovement()
      # TODO 1 vs 3 comparisons if checkposition is false
      #     else if checkPosition
      #       if @position.y == @oldPosition.y
      #         ...
      else if checkPosition and @position.y == @oldPosition.y
        @stopMovement()
        @tryOtherDirection = true
      else
        @physBody.SetLinearVelocity(new @level.physicsManager.Vec2(0, @velocity))
    else if @moving.up
      if @position.y < @targetPos.y
        @stopMovement()
      else if checkPosition and @position.y == @oldPosition.y
        @stopMovement()
        @tryOtherDirection = true
      else
        @physBody.SetLinearVelocity(new @level.physicsManager.Vec2(0, -@velocity))
    else if @moving.right
      if @position.x > @targetPos.x
        @stopMovement()
      else if checkPosition and @position.x == @oldPosition.x
        @stopMovement()
        @tryOtherDirection = true
      else
        @physBody.SetLinearVelocity(new @level.physicsManager.Vec2(@velocity, 0))
    else if @moving.left
      if @position.x < @targetPos.x
        @stopMovement()
      else if checkPosition and @position.x == @oldPosition.x
        @stopMovement()
        @tryOtherDirection = true
      else
        @physBody.SetLinearVelocity(new @level.physicsManager.Vec2(-@velocity, 0))
    else
      task = @tasks.shift()
      if task
        task.apply(@)
      else if @onFollow
        @moveToPosition(@positionToMoveTo, @maxDistance)

    # TODO the fewest entities need this block
    @oldPosition = _.clone(@position) if checkPosition


  addTask: (task) =>
    @tasks.push task


  blockInput: () =>
    @tasks.push ->
      require('mediator').blockInput = true


  unblockInput: () =>
    @tasks.push ->
      require('mediator').blockInput = false


  getActualMoveDistance: (distance) =>
    return @maxDistance if distance > @maxDistance
    return distance


  moveOnXAxis: (ax, dx) =>
    distance = @getActualMoveDistance(ax)
    # if dx > 0 move right else move left
    if dx > 0
      @moveRight(distance)
    else
      @moveLeft(distance)

  moveOnYAxis: (ay, dy) =>
    distance = @getActualMoveDistance(ay)
    # if dy > 0 move down else move up
    if dy > 0
      @moveDown(distance)
    else
      @moveUp(distance)


  moveToPosition:(positionToMoveTo, maxDistance) =>
    @tasks.push () ->
      # first call
      if not @onFollow
        @positionToMoveTo = positionToMoveTo
        @onFollow = true
        # max distance the entity can move in one timeStep
        @maxDistance = maxDistance
        @savedTasks = _.clone(@tasks)
        @tasks = []

      threshold = @velocity / 50
      threshold = 1 if threshold < 1

      # dx = x2 - x1
      dx = Math.floor(positionToMoveTo.x - @position.x)
      dy = Math.floor(positionToMoveTo.y - @position.y)
      # ax = |x2 - x1| = d(x1, x2)
      ax = Math.abs(dx)
      ay = Math.abs(dy)

      # if positionToMoveTo reached stop
      if (ax <= threshold and ay <= threshold) or (@position.x == positionToMoveTo.x and @position.y == positionToMoveTo.y)
        @position.x = positionToMoveTo.x
        @position.y = positionToMoveTo.y
        @positionToMoveTo = null
        @onFollow = false
        @tasks = @savedTasks
        return


      # needs mor tweaking, yeti still gets stuck
      if      ax >= ay and not @tryOtherDirection # if absolute distance x > absolute distance y
        @moveOnXAxis(ax, dx)

      else if ax >= ay and @tryOtherDirection
        @tryOtherDirection = false
        @moveOnYAxis(ay, dy)

      else if ax <= ay and not @tryOtherDirection # if absolute distance x < absolute distance y
        @moveOnYAxis(ay, dy)

      else if ax <= ay and @tryOtherDirection
        @tryOtherDirection = false
        @moveOnXAxis(ax, dx)
