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
      # remove task if finished
      # @_tasks.shift() if task.apply @


  ###
  @param [function] task Must return a {Result}
  ###
  addTask: (task) =>
    @_tasks.push task
      # task.apply @
