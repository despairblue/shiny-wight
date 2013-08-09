###
A Result represents the...well...result of a Task.

Any function given to {Scriptable#addTask} is expected to return a {Result}.
###

module.exports = class Result

  ###
  @property [Boolean]
  Represents wether the Task returning this Result has finished.
  ###
  done:true

  ###
  @property [Function]
  The next Task that should be called before handling other ones.
  ###
  next:null

  ###
  @property [Array]
  The arguments that should be passed to {#next}
  ###
  arguments:null

  ###
  @param [Boolean] done see {#done}
  @param [Function] next see {#next}
  @param [Array] args... see {#arguments}
  ###
  constructor: (@done, @next, args...) ->
    @arguments = args
