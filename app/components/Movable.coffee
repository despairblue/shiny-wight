Component = require 'core/Component'
Result = require 'core/Result'

###
Depends on Scriptable
###
module.exports = class Movable extends Component
  constructor: (owner) ->
    super

    # check dependencies
    unless @owner.scriptable
      console.error 'Movable depends on the Scriptable component. %O does not have one', @owner

    @oldPosition =
      x: 0
      y: 0

    @moving =
      up: false
      down: false
      right: false
      left: false

    # TODO the fewest entities need this block (only player and NPCs/Monsters, in my humble opinion)
    @maxDistance = 0
    @positionToMoveTo = null
    @onFollow = false
    @counter = 0
    @tryOtherDirection = false

    @positionCheckTimer = Date.now()


  # TODO maybe add velocity to define the speed of movement
  # Example: Yeties moving slowly, then see the player and go fast to him..
  moveDown: (pixel) =>
    deferred = Q.defer()
    console.assert pixel > 0, 'argument must be a positive integer'
    @owner.scriptable.addTask => @_moveDown pixel, deferred
    return deferred.promise


  moveUp: (pixel) =>
    deferred = Q.defer()
    console.assert pixel > 0, 'argument must be a positive integer'
    @owner.scriptable.addTask => @_moveUp pixel, deferred
    return deferred.promise


  moveRight: (pixel) =>
    deferred = Q.defer()
    console.assert pixel > 0, 'argument must be a positive integer'
    @owner.scriptable.addTask => @_moveRight pixel, deferred
    return deferred.promise


  moveLeft: (pixel) =>
    deferred = Q.defer()
    console.assert pixel > 0, 'argument must be a positive integer'
    @owner.scriptable.addTask => @_moveLeft pixel, deferred
    return deferred.promise


  _moveDown: (pixel, deferred) =>
    if @moving.down
      if @owner.position.y > @targetPos.y
        @stopMovement()
        # task finished
        deferred.resolve(@)
        return new Result true
      else if @checkPosition and @owner.position.y == @oldPosition.y
        @stopMovement()
        @tryOtherDirection = true

        # task finished
        deferred.resolve(@)
        return new Result true
      else
        @owner.physBody.SetLinearVelocity(new @owner.level.physicsManager.Vec2(0, @owner.velocity))

        # task not yet finished
        return new Result false, @_moveDown, pixel, deferred
    else
      # first call to task
      console.debug 'Move %O%i down.', @owner, pixel
      # bootstrap
      @targetPos =
        x: @owner.position.x
        y: @owner.position.y + pixel
      @moving.down = true
      @owner.visual.spriteState.moving = true
      @owner.visual.spriteState.viewDirection = 2

      # task not finished
      return new Result false, @_moveDown, pixel, deferred


  _moveUp: (pixel, deferred) =>
    if @moving.up
      if @owner.position.y < @targetPos.y
        @stopMovement()
        deferred.resolve(@)
        return new Result true
      else if @checkPosition and @owner.position.y == @oldPosition.y
        @stopMovement()
        @tryOtherDirection = true
        deferred.resolve(@)
        return new Result true
      else
        @owner.physBody.SetLinearVelocity(new @owner.level.physicsManager.Vec2(0, -@owner.velocity))
        return new Result false, @_moveUp, pixel, deferred
    else
      console.debug 'Move %O%i up.', @owner, pixel
      @targetPos =
        x: @owner.position.x
        y: @owner.position.y - pixel
      @moving.up = true
      @owner.visual.spriteState.moving = true
      @owner.visual.spriteState.viewDirection = 0
      return new Result false, @_moveUp, pixel, deferred


  _moveRight: (pixel, deferred) =>
    if @moving.right
      if @owner.position.x > @targetPos.x
        @stopMovement()
        deferred.resolve(@)
        return new Result true
      else if @checkPosition and @owner.position.x == @oldPosition.x
        @stopMovement()
        @tryOtherDirection = true
        deferred.resolve(@)
        return new Result true
      else
        @owner.physBody.SetLinearVelocity(new @owner.level.physicsManager.Vec2(@owner.velocity, 0))
        return new Result false, @_moveRight, pixel, deferred
    else
      console.debug 'Move %O%i right.', @owner, pixel
      @targetPos =
        x: @owner.position.x + pixel
        y: @owner.position.y
      @moving.right = true
      @owner.visual.spriteState.moving = true
      @owner.visual.spriteState.viewDirection = 1
      return new Result false, @_moveRight, pixel, deferred


  _moveLeft: (pixel, deferred) =>
    if @moving.left
      if @owner.position.x < @targetPos.x
        @stopMovement()
        deferred.resolve(@)
        return new Result true
      else if @checkPosition and @owner.position.x == @oldPosition.x
        @stopMovement()
        @tryOtherDirection = true
        deferred.resolve(@)
        return new Result true
      else
        @owner.physBody.SetLinearVelocity(new @owner.level.physicsManager.Vec2(-@owner.velocity, 0))
        return new Result false, @_moveLeft, pixel, deferred
    else
      console.debug 'Move %O%i left.', @owner, pixel
      @targetPos =
        x: @owner.position.x - pixel
        y: @owner.position.y
      @moving.left = true
      @owner.visual.spriteState.moving = true
      @owner.visual.spriteState.viewDirection = 3
      return new Result false, @_moveLeft, pixel, deferred


  stopMovement: () =>
    @owner.physBody.SetLinearVelocity(new @owner.level.physicsManager.Vec2(0, 0))
    @moving.down        = false
    @moving.up          = false
    @moving.left        = false
    @moving.right       = false
    @owner.visual.spriteState.moving = false


  getActualMoveDistance: (distance) =>
    return @maxDistance if distance > @maxDistance
    return distance


  moveOnXAxis: (ax, dx) =>
    distance = @getActualMoveDistance(ax)
    # if dx > 0 move in positive direction of x-axis, i.e. right else left
    if dx > 0
      @moveRight(distance)
    else
      @moveLeft(distance)

  moveOnYAxis: (ay, dy) =>
    distance = @getActualMoveDistance(ay)
    # if dy > 0 move in positive direction of y-axis, i.e. down else move up
    if dy > 0
      @moveDown(distance)
    else
      @moveUp(distance)


  # TODO: broken, fix it
  moveToPosition:(@positionToMoveTo, @maxDistance) =>
    @owner.scriptable.addTask =>
      # first call
      if not @onFollow
        @onFollow = true
        @owner.scriptable.tasks.shift() # remove itself from tasks to prevent endless loop
        @savedTasks = _.clone(@owner.scriptable.tasks)
        @owner.scriptable.tasks = []

      threshold = @owner.velocity / 50
      threshold = 3 if threshold < 3

      # dx = x2 - x1
      dx = Math.floor(@positionToMoveTo.x - @owner.position.x)
      dy = Math.floor(@positionToMoveTo.y - @owner.position.y)
      # ax = |x2 - x1| = d(x1, x2)
      ax = Math.abs(dx)
      ay = Math.abs(dy)

      # if @positionToMoveTo reached stop
      # if (ax <= threshold and ay <= threshold) or (@owner.position.x == positionToMoveTo.x and @owner.position.y == positionToMoveTo.y)
      if (@positionToMoveTo.x - threshold < @owner.position.x < @positionToMoveTo.x + threshold) and (@positionToMoveTo.y - threshold < @owner.position.y < @positionToMoveTo.y + threshold)
        @owner.position.x = @positionToMoveTo.x
        @owner.position.y = @positionToMoveTo.y
        @positionToMoveTo = null
        @onFollow = false
        @owner.scriptable.tasks = @savedTasks
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
