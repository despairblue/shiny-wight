Component = require 'core/components/Component'

###
###
module.exports = class Scriptable extends Component
  constructor: (@owner) ->
    @_tasks = []

    @owner.addListener 'update', @_scriptable_update


  _scriptable_update: =>
    # get current task
    task = @_tasks[0]
    if task
      # remove task if finished
      @_tasks.shift() if task.apply @


  addSimpleTask: (task) =>
    @_tasks.push ->
      task.apply @
      return true

  addTask: (task) =>
    @_tasks.push ->
      task.apply @
