###
A Result represents the...well...result of a Task.

Any function given to {Scriptable#addTask} is expected to return a {Result}.
###

module.exports = class Component
  constructor: (@owner) ->

  ###
  Copys all functions from the component to {#owner}.
  Ignores functions starting with an underscore and refuses to
  overwrite functions.
  ###
  mount: () =>
    for method of @
      if method[0] is '_' or      # don't copy private methods
      method == 'owner' or        # the owner property pointing to the components owner
      method == 'constructor' or  # the constructor
      method == 'mount'           # this method
        continue
      if @owner[method]?
        console.debug 'Method %s exists already and will not be mounted on %O', method, @owner
        continue
      @owner[method] = do (method) => =>
        @[method].apply @, arguments
