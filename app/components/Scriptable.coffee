Component = require 'core/Component'
Result = require 'core/Result'

###
###
module.exports = class Scriptable extends Component
  constructor: (owner) ->
    super

    @_tasks = []

    @owner.addListener 'update', @_scriptable_update


  _scriptable_update: =>
    # get current task
    task = @_tasks[0]
    if task
      result = task()
      console.assert result instanceof Result, 'Task did not return Result object'
      if result.done?
        @_tasks.shift()
        if result.next?
          @_tasks.unshift -> result.next.apply null, result.arguments


  addScripts: (scripts) =>
    deferred = Q.defer()

    @_executeScripts scripts, deferred

    return deferred.promise

  _executeScripts: (scripts, deferred) =>
    if scripts.length == 0
      deferred.resolve()
    else
      script = scripts.shift()
      # An array? Ok, let's see what thw arrays first element is
      if script instanceof Array
        # An Array again? Ok then
        if script[0] instanceof Array
          debugger
          promises = ( @addScripts s for s in script )
          window.promises = promises
          promise = Q.all(promises)
          window.promise = promise
          promise.then =>
            debugger
            console.debug arguments
            @_executeScripts scripts, deferred

        else if script[0] instanceof Function
          # args = if (script[1] instanceof Array) then script[1] Array else [script[1]]
          args = script.slice 1
          promise = script[0].apply null, args
          # console.debug "#{script[0]}(#{args});"
          promise.then =>
            console.debug arguments
            @_executeScripts scripts, deferred
      # Just a function? Call it!
      else if script instanceof Function
        promise = script.apply()
        promise.then =>
          console.debug arguments
          @_executeScripts scripts, deferred

  ###
  @param [function] task Must return a {Result}
  ###
  addTask: (task) =>
    @_tasks.push task
      # task.apply @
