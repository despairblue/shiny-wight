module.exports =

  # Call this in the construcotr before you call super
  _movable_setUp: (pathToAtlas) ->
    # set up sane defaults
    @movable = true

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

    # TODO: move to own mixin
    @tasks = []


  # Call this in the constructor after you call super
  _movable_init: () ->
    @loadMethods.push @_visual_load
    @updateMethods.push @_movable_update

    @positionCheckTimer = Date.now()


  # Will be called when Entity.load is called
  _movable_load: ->


  _movable_update: ->
    checkPosition = false

    # TODO not all entities need the following block.. actually the fewest entities need this
    # so move it into a subclass to increase performance
    # TODO: this breaks stuff, checkposition is true when the yeti won't move for 2 seconds, what if he's not supposed to move?
    # TODO: move task management to own mixin

    # get current task
    task = @tasks[0]

    if task
      # remove task if finished
      @tasks.shift() if task.apply @

    else if @onFollow
      @counter +=1
      if @counter % 10 == 0
        @counter = 1
        if Date.now() - @positionCheckTimer > 2000
          @checkPosition = true
          @positionCheckTimer == Date.now()
          # TODO the fewest entities need this block
          @oldPosition = _.clone(@position) # if checkPosition
      @moveToPosition(@positionToMoveTo, @maxDistance)



  # TODO maybe add velocity to define the speed of movement
  # Example: Yeties moving slowly, then see the player and go fast to him..
  moveDown: (pixel) ->
    console.error 'argument must be an positive integer' if pixel < 0
    @tasks.push () ->
      if @moving.down
        if @position.y > @targetPos.y
          @stopMovement()
          # task finished
          return true
        else if @checkPosition and @position.y == @oldPosition.y
          @stopMovement()
          @tryOtherDirection = true

          # task finished
          return true
        else
          @physBody.SetLinearVelocity(new @level.physicsManager.Vec2(0, @velocity))

          # task not yet finished
          return false
      else
        # first call to task

        # bootstrap
        @targetPos =
          x: @position.x
          y: @position.y + pixel
        @moving.down = true
        @spriteState.moving = true
        @spriteState.viewDirection = 2

        # task not finished
        return false

    return @


  moveUp: (pixel) ->
    console.error 'argument must be an positive integer' if pixel < 0
    @tasks.push () ->
      if @moving.up
        if @position.y < @targetPos.y
          @stopMovement()
          return true
        else if @checkPosition and @position.y == @oldPosition.y
          @stopMovement()
          @tryOtherDirection = true
          return true
        else
          @physBody.SetLinearVelocity(new @level.physicsManager.Vec2(0, -@velocity))
          return false
      else
        @targetPos =
          x: @position.x
          y: @position.y - pixel
        @moving.up = true
        @spriteState.moving = true
        @spriteState.viewDirection = 0
        return false

    return @


  moveRight: (pixel) ->
    console.error 'argument must be an positive integer' if pixel < 0
    @tasks.push () ->
      if @moving.right
        if @position.x > @targetPos.x
          @stopMovement()
          return true
        else if @checkPosition and @position.x == @oldPosition.x
          @stopMovement()
          @tryOtherDirection = true
          return true
        else
          @physBody.SetLinearVelocity(new @level.physicsManager.Vec2(@velocity, 0))
          return false
      else
        @targetPos =
          x: @position.x + pixel
          y: @position.y
        @moving.right = true
        @spriteState.moving = true
        @spriteState.viewDirection = 1
        return false

    return @


  moveLeft: (pixel) ->
    console.error 'argument must be an positive integer' if pixel < 0
    @tasks.push () ->
      if @moving.left
        if @position.x < @targetPos.x
          @stopMovement()
          return true
        else if @checkPosition and @position.x == @oldPosition.x
          @stopMovement()
          @tryOtherDirection = true
          return true
        else
          @physBody.SetLinearVelocity(new @level.physicsManager.Vec2(-@velocity, 0))
          return false
      else
        @targetPos =
          x: @position.x - pixel
          y: @position.y
        @moving.left = true
        @spriteState.moving = true
        @spriteState.viewDirection = 3
        return false

    return @


  # TODO: (pixel)??
  stopMovement: (pixel) ->
    @physBody.SetLinearVelocity(new @level.physicsManager.Vec2(0, 0))
    @moving.down        = false
    @moving.up          = false
    @moving.left        = false
    @moving.right       = false
    @spriteState.moving = false


  getActualMoveDistance: (distance) ->
    return @maxDistance if distance > @maxDistance
    return distance


  moveOnXAxis: (ax, dx) ->
    distance = @getActualMoveDistance(ax)
    # if dx > 0 move in positive direction of x-axis, i.e. right else left
    if dx > 0
      @moveRight(distance)
    else
      @moveLeft(distance)

  moveOnYAxis: (ay, dy) ->
    distance = @getActualMoveDistance(ay)
    # if dy > 0 move in positive direction of y-axis, i.e. down else move up
    if dy > 0
      @moveDown(distance)
    else
      @moveUp(distance)


  # TODO: broken, fix it
  moveToPosition:(@positionToMoveTo, @maxDistance) ->
    @tasks.push () ->
      # first call
      if not @onFollow
        @onFollow = true
        @tasks.shift() # remove itself from tasks to prevent endless loop
        @savedTasks = _.clone(@tasks)
        @tasks = []

      threshold = @velocity / 50
      threshold = 3 if threshold < 3

      # dx = x2 - x1
      dx = Math.floor(@positionToMoveTo.x - @position.x)
      dy = Math.floor(@positionToMoveTo.y - @position.y)
      # ax = |x2 - x1| = d(x1, x2)
      ax = Math.abs(dx)
      ay = Math.abs(dy)

      # if @positionToMoveTo reached stop
      # if (ax <= threshold and ay <= threshold) or (@position.x == positionToMoveTo.x and @position.y == positionToMoveTo.y)
      if (@positionToMoveTo.x - threshold < @position.x < @positionToMoveTo.x + threshold) and (@positionToMoveTo.y - threshold < @position.y < @positionToMoveTo.y + threshold)
        @position.x = @positionToMoveTo.x
        @position.y = @positionToMoveTo.y
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
