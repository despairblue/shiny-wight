Model = require 'models/base/model'
mediator = Chaplin.mediator

module.exports = class Std extends Model
  initialize: ->
    mediator.std = @


  ###
  Starts a XMLHttpRequest and calls the given callback when finished loading.
  @param [String] reqUri URI to the file to be loaded
  @param [Function] callback Callback function
  @param [String] responseType
  @param [Objects] additionalAttributes Will be added as an array to XMLHttpRequest.additionalAttributes
  ###
  xhrGet: (reqUri, callback, responseType, additionalAttributes...) ->
    xhr = new XMLHttpRequest()
    xhr.responseType = responseType if responseType?
    xhr.additionalAttributes = additionalAttributes
    xhr.open 'GET', reqUri, true
    xhr.onload = callback
    xhr.send()
