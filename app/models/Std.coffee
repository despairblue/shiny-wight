Model = require 'models/base/model'
mediator = require 'mediator'

module.exports = class Std extends Model


  initialize: ->
    mediator.std = @


  ###
  Starts a XMLHttpRequest and calls the given callback when finished loading.
  @param [String] reqUri URI to the file to be loaded
  @param [Function] callback Callback function
  ###
  xhrGet: (reqUri, callback, rest...) ->
    xhr = new XMLHttpRequest()
    xhr.responseType = rest[0] if rest.length isnt 0
    xhr.additionalAttributes = rest.splice 1
    xhr.open 'GET', reqUri, true
    xhr.onload = callback
    xhr.send()