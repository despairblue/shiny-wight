Model = require 'models/base/model'
mediator = require 'mediator'

module.exports = class Level extends Model
  soundList: {}
  backgroundSounds: {}

  # to check whether all sounds loaded
  soundLoadCount: 0
  soundCount: 0

  physicsMap: []

  gMap: null

  loadCompleted = false

  constructor: (manifestUri, callback) ->
    mediator.std.xhrGet manifestUri, (data) =>
      manifest = JSON.parse data.target.responseText
      @[prop] = content for prop, content of manifest
      @loadCompleted = true
      callback() if callback

  setup: =>
    if @loadCompleted
      # ...
    else
      console.error "Don't call Level.setup() unless the manifest finished loading"

