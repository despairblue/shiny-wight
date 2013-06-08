###
@mixin
###

Scriptable =
  setUpMethod: ->
    # set up sane defaults
    @scriptable = true

    @tasks = []
    @updateMethods.push @_scriptable_update


  addTask: (task) ->
    @tasks.push ->
      task.apply @
      return true


  _scriptable_update: ->
    # get current task
    task = @tasks[0]

    if task
      # remove task if finished
      @tasks.shift() if task.apply @


# necessary hack for codo support
module.exports = Scriptable
