Component = require 'core/components/Component'

###
###
module.exports = class Scriptable extends Component
  constructor: (@owner) ->
    # set up sane defaults
    @scriptable = true
    @_tasks = []


    scriptable_update = =>
      # get current task
      task = @tasks[0]
      if task
        # remove task if finished
        @tasks.shift() if task.apply @

    @owner.updateMethods.push scriptable_update


  addSimpleTask: (task) =>
    @_tasks.push ->
      task.apply @
      return true

  addTask: (task) =>
    @_tasks.push ->
      task.apply @
