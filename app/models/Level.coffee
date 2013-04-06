Model = require 'models/base/model'
PhysicsManager = require 'models/PhysicsManager'
mediator = require 'mediator'

module.exports = class Level extends Model
  manifest: null
  _callback: null

  # Sounds
  soundList: {}
  backgroundSoundList: {}
  #soundTheme: null

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

  constructor: (manifestUri, @_callback) ->
    mediator.std.xhrGet manifestUri, (data) =>
      @manifest = JSON.parse data.target.responseText

      # load the config files for the entities
      @bodyCount = @manifest.entities.files.length
      for file in @manifest.entities.files
        mediator.std.xhrGet @manifest.entities.prefix + '/' + file, (data) =>
          ent = JSON.parse data.target.responseText
          @entities[ent.tiledName] = ent
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
          @physicsManager.addContactListener PostSolve: (bodyA, bodyB, impulse) ->
            dataA = bodyA.GetUserData()
            dataB = bodyB.GetUserData()
            dataA?.ent.onTouch bodyB, null, impulse
            dataB?.ent.onTouch bodyA, null, impulse
          , BeginContact: (bodyA, bodyB) ->
            dataA = bodyA.GetUserData()
            dataB = bodyB.GetUserData()
            dataA?.ent.onTouchBegin bodyB, null
            dataB?.ent.onTouchBegin bodyA, null
          , EndContact: (bodyA, bodyB) ->
            dataA = bodyA.GetUserData()
            dataB = bodyB.GetUserData()
            dataA?.ent.onTouchEnd bodyB, null
            dataB?.ent.onTouchEnd bodyA, null

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
            # done loading sounds


  setup: =>
    if @loadCompleted
      @initialSpawn()
    else
      console.error "Don't call Level.setup() unless the manifest finished loading"


  checkIfDone: =>
    if @bodiesLoaded and @mapLoaded and (@soundsLoaded or !mediator.playWithSounds)
      console.log "level load completed" if debug
      @loadCompleted = true
      @_callback() if @_callback


  initialSpawn: (level) =>
    level = mediator.getActiveLevel() unless level

    map = level.mapTiledObject

    for layer in map.layers
      continue if layer.type is 'tilelayer'
      continue if layer.name isnt 'spawnpoints'

      for object in layer.objects
        continue if object.type is ''

        obj = @createEntity object

        mediator.entities.push(obj)
        if object.type == "Player"
            mediator.player = obj

  createEntity: (object) =>
    # get constructor and json config
    Ent = mediator.factory[object.type]


    # use the properties defined in tiled
    if Object.keys(object.properties).length isnt 0
      conf = {}
      conf[prop] = content for prop, content of object.properties
    else
      # otherwise use a configuration file
      conf = @entities[object.name]

    if not conf
      console.error "No configuration file found for #{object.name}"
      return "No configuration found!"

    conf.ellipse = true if object.ellipse

    # sanitize constructor attributes
    x = Math.floor object.x
    y = Math.floor object.y
    width = Math.floor object.width
    height = Math.floor object.height

    # initialize object with position, size and config
    obj = new Ent(x, y, width, height, @, conf)

    obj.load()

    return obj


  update: =>
    @physicsManager.update()
