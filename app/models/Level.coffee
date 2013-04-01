Model = require 'models/base/model'
mediator = require 'mediator'

module.exports = class Level extends Model
  manifest: null
  soundList: {}
  backgroundSounds: {}

  # to check whether all sounds loaded
  soundLoadCount: 0
  soundCount: 0

  physicsMap: []

  entities: {}
  bodyCount: 0

  gMap: null

  loadCompleted = false

  constructor: (manifestUri, callback) ->
    mediator.std.xhrGet manifestUri, (data) =>
      @manifest = JSON.parse data.target.responseText

      # just copy sounds and map from the manifest and let the managers load it
      @sounds = @manifest.sounds
      @map = @manifest.map

      # load the config files for the entities
      @bodyCount = @manifest.entities.files.length
      for file in @manifest.entities.files
        mediator.std.xhrGet @manifest.entities.prefix + '/' + file, (data) =>
          ent = JSON.parse data.target.responseText
          @entities[ent.name] = ent
          @bodyCount--
          if @bodyCount <= 0
            @loadCompleted = true
            callback() if callback


  setup: =>
    if @loadCompleted
      # ...
    else
      console.error "Don't call Level.setup() unless the manifest finished loading"
