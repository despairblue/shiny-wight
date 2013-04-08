Model           = require 'models/base/model'
PhysicsManager  = require 'models/PhysicsManager'
mediator        = require 'mediator'

module.exports = class Level extends Model

  constructor: (manifestUri, @_callback) ->
    # Object Properties
    @manifest            = null
    @tasks = []

    # Sounds
    @mapSoundList     = {}
    @backgroundSoundList = {}
    @soundTheme          = null
    @soundCount          = 0

    # Physics
    @b2World             = null
    @physicsLoopHZ       = 1/25

    # Entities
    @entities            = {}
    @entityObjects       = []
    @player              = null
    @bodyCount           = 0

    # Tiled Map
    @mapCanvas           = null
    @mapTiledObject      = null
    @tileSets            = null

    # Loading States
    @bodiesLoaded        = false
    @mapLoaded           = false
    @loadCompleted       = false
    @setupped            = false

    mediator.std.xhrGet manifestUri, (data) =>
      @manifest = JSON.parse data.target.responseText

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

          # load the config files for the entities
          @loadEntitiesConfigs()

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
          @mapSoundList         = @manifest.sounds.sounds
          @backgroundSoundList  = @manifest.sounds.backgroundSounds
          @themeSound           = @manifest.sounds.theme
          if @manifest.sounds.themeIntensity?
            @themeIntensity     = @manifest.sounds.themeIntensity
          else @themeIntensity  = 1

          @soundCount = @mapSoundList.length + @backgroundSoundList.length + 1

          mediator.soundManager.loadSounds @manifest.sounds, =>
            @soundCount--
            if @soundCount <= 0
              @soundsLoaded = true
              @checkIfDone()
            # done loading sounds


  loadEntitiesConfigs: =>
    if not @mapLoaded
      console.error 'Do not call loadEntities unless the map finished loading and parsing!'

    @manifest.entities.files = [] unless @manifest.entities.files?
    list = @manifest.entities.files

    for layer in @mapTiledObject.layers
      continue if layer.type is 'tilelayer'
      continue if layer.name isnt 'spawnpoints'

      for object in layer.objects
        continue if object.type is ''

        if Object.keys(object.properties).length is 0
          list.push object.name + '.json'

    @bodyCount = list.length
    for file in list
      uri = @manifest.entities.prefix + '/' + file
      console.log "Try to load #{uri}"
      mediator.std.xhrGet uri, (data) =>
        try
          ent = JSON.parse data.target.responseText
          @entities[ent.tiledName] = ent
        catch e
          console.error e
          console.error "Error loading config file!"

        @bodyCount--
        if @bodyCount <= 0
          @bodiesLoaded = true
          @checkIfDone()

    return list


  setup: =>
    if @loadCompleted
      if not @setupped
        @setupped = true
        @initialSpawn()
      else
        console.error "Level already set up!"
    else
      console.error "Don't call Level.setup() unless the manifest finished loading!"


  checkIfDone: =>
    if @bodiesLoaded and @mapLoaded and (@soundsLoaded or !mediator.playWithSounds)
      console.log "load level completed" if debug
      @loadCompleted = true
      @_callback() if @_callback


  initialSpawn: () =>
    for layer in @mapTiledObject.layers
      continue if layer.type is 'tilelayer'
      continue if layer.name isnt 'spawnpoints'

      for object in layer.objects
        continue if object.type is ''

        obj = @addEntity object

        if object.type == "Player"
          @player = obj

  addEntity: (object) =>
    obj = @createEntity object
    @entityObjects.push obj
    return obj

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
      return null

    conf.name = object.name

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
    ent.update() for ent in @entityObjects

    for task, index in @tasks
      task()

    @tasks = []


  updatePhysics: =>
    @physicsManager.update()

