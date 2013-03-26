Model = require 'models/base/model'
mediator = require 'mediator'

module.exports = class std extends Model


  initialize: ->
    mediator.std = @


  ###
  Starts a XMLHttpRequest and calls the given callback when finished loading.
  @param [String] reqUri URI to the file to be loaded
  @param [Function] callback Callback function
  @todo move to a library
  ###
  xhrGet: (reqUri, callback, rest...) ->
    xhr = new XMLHttpRequest()
    xhr.additionalAttributes = rest
    xhr.open 'GET', reqUri, true
    xhr.onload = callback
    xhr.send()
