module.exports = class Component
  constructor: (@owner) ->


  mount: () =>
    for method of @
      if @owner[method]?
        console.debug 'Method %s exists already and will not be mounted on %O', method, @owner
        continue
      if method[0] is '_'
        continue
      @owner[method] = do (method) => =>
        @[method].apply @, arguments
