Model           = require 'models/base/model'
PhysicsManager  = require 'models/PhysicsManager'
mediator        = require 'mediator'

module.exports = class Level extends Model

  constructor: (manifestId, @_callback) ->
    # Object Properties
    @manifest            = null
    @_tasks = []

    # Sounds
    @mapSoundList     = {}
    @backgroundSoundList = {}
    @soundTheme          = null
    @soundCount          = 0

    # Physics
    @physicsManager

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
    @soundsLoaded        = false

    @manifest = mediator.configurationManager.configure {}, manifestId

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
    if @mapLoaded and (@soundsLoaded or !mediator.playWithSounds)
      console.log "Finished loading #{@manifest.map.file}" if debug
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


  removeEntity: (entity) =>
    # must be delayed to make sure that this won't happen while iterating over the entityObjects array
    @_tasks.push ->
      index = @entityObjects.indexOf entity
      @entityObjects.splice index, 1


  createEntity: (object) =>
    # get constructor
    Ent  = mediator.factory[object.type]

    # try to use the new config manager
    configurator = mediator.configurationManager[object.name]

    unless configurator?
      console.error "Warning: No configurations found for #{object.name}"

    # initialize object passing in the owning lvl and a copy of the tiled object
    obj = new Ent @, _.clone object

    # apply custom configuration if there is any
    configurator.apply obj if configurator

    obj.load()

    return obj


  update: =>
    ent.update() for ent in @entityObjects

    for task, index in @_tasks
      task.apply @

    @_tasks = []


  updatePhysics: =>
    @physicsManager.update()


  # TODO: merge with scriptable
  addTask: (task) =>
    @_tasks.push ->
      task.apply @
