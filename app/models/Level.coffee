Model = require 'models/base/model'
mediator = require 'mediator'

module.exports = class Level extends Model
  manifest: null
  callback: null

  soundList: {}
  backgroundSounds: {}

  soundCount: 0

  physicsMap: []

  entities: {}
  bodyCount: 0

  mapCanvas: null
  mapTiledObject: null

  bodiesLoaded: false
  mapLoaded: false
  loadCompleted: false

  constructor: (manifestUri, @callback) ->
    mediator.std.xhrGet manifestUri, (data) =>
      @manifest = JSON.parse data.target.responseText

      # load the config files for the entities
      @bodyCount = @manifest.entities.files.length
      for file in @manifest.entities.files
        mediator.std.xhrGet @manifest.entities.prefix + '/' + file, (data) =>
          ent = JSON.parse data.target.responseText
          @entities[ent.name] = ent
          @bodyCount--
          if @bodyCount <= 0
            @bodiesLoaded = true
            @checkIfDone()




      # load map
      mediator.std.xhrGet @manifest.map.prefix + '/' + @manifest.map.file, (data) =>
        @mapTiledObject = JSON.parse data.target.responseText
        mediator.mapManager.renderZwei @mapTiledObject, (map, tileSets) =>
          @mapCanvas = map
          @tileSets = tileSets
          @mapLoaded = true
          @checkIfDone()
        # load sounds
        if mediator.playWithSounds
          # just copy sounds from the manifest and let the managers load it
          @soundCount = @manifest.sounds.sounds.length + 1 + @manifest.sounds.backgroundSounds.length
          @soundMap = mediator.soundManager.getSoundMap(@mapTiledObject)



  setup: =>
    if @loadCompleted
      # ...
    else
      console.error "Don't call Level.setup() unless the manifest finished loading"

  checkIfDone: =>
    if @bodiesLoaded and @mapLoaded
      @loadCompleted = true
      @callback() if @callback
