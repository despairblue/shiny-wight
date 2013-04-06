Model = require 'models/base/model'
PhysicsManager = require 'models/PhysicsManager'
mediator = require 'mediator'

module.exports = class Level extends Model
  manifest: null
  callback: null

  # Sounds
  soundList: {}
  backgroundSoundList: {}
  soundTheme: null

  soundCount: 0

  # Physics
  physicsMap: []
  b2World: null
  physicsLoopHZ: 1/25

  # Entities
  entities: {}
  bodyCount: 0

  # Tiled Map
  mapCanvas: null
  mapTiledObject: null
  tileSets: null

  # Loading States
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
        mediator.mapManager.parse @mapTiledObject, (map, tileSets) =>
          @mapCanvas = map
          @tileSets = tileSets
          # TODO: this is ugly and only needed for physicsmanager
          @mapTiledObject.processedTileSets = @tileSets
          @mapLoaded = true
          # done parsing and rendering tiled map

          # create physics world
          @physicsManager = new PhysicsManager(@mapTiledObject)

          @checkIfDone()
        # load sounds
        if mediator.playWithSounds
          # just copy sounds from the manifest and let the managers load it
          @soundMap = mediator.soundManager.getSoundMap @mapTiledObject
          mediator.soundManager.loadSounds @manifest.sounds, (soundList, backgroundSoundList, themeSound) =>
            @soundList = soundList
            @backgroundSoundList = backgroundSoundList
            @themeSound = themeSound
            @soundsLoaded = true
            @checkIfDone()


  setup: =>
    if @loadCompleted
      # ...
    else
      console.error "Don't call Level.setup() unless the manifest finished loading"

  checkIfDone: =>
    if @bodiesLoaded and @mapLoaded and (@soundsLoaded or !mediator.playWithSounds)
      console.log "level load completed" if debug
      @loadCompleted = true
      @callback() if @callback
  update: =>
    @physicsManager.update()
