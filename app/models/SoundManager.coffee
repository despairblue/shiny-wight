Model = require 'models/base/model'
SoundObj = require 'models/SoundObj'
mediator = require 'mediator'

module.exports = class SoundManager extends Model

  audioContext: null
  soundList: {}
  backgroundSounds: {}

  # to check whether all sounds loaded
  soundLoadCount: 0
  soundCount: 0

  PATH: 'sounds/'
  FADE_TIME_INTERVAL: 1


  initialize: =>
    super
    mediator.soundManager = @

    @audioContext = new webkitAudioContext()


  initializeSoundMap: =>
    map = mediator.map
    currMapData = map.currMapData

    @soundMap = []
    for x in [0..map.numXTiles - 1]
      @soundMap[x] = for y in [0..map.numYTiles - 1]
        []


    for layer in currMapData.layers
      continue if layer.name isnt 'sound'

      for tileID, tileIndex in layer.data
        continue if tileID is 0

        x = (tileIndex % map.numXTiles)
        y = Math.floor(tileIndex / map.numXTiles)

        @soundMap[x][y].push(layer.properties)


  load: (level) =>
    @subscribeEvent 'map:rendered', =>
      @initializeSoundMap()
      mediator.std.xhrGet level, (data) =>
        mapSounds = JSON.parse data.target.responseText
        @soundCount =  mapSounds.sounds.length + mapSounds.backgroundSounds.length
        @backgroundSoundsToPlay = new Array(@soundCount)
        @loadSounds mapSounds



  loadSounds: (mapSounds) =>
    for sound in mapSounds.sounds
      @soundList[sound] = new SoundObj
      mediator.std.xhrGet @PATH+sound+'.mp3', @bufferSounds, 'arraybuffer', sound, @soundList

    for sound in mapSounds.backgroundSounds
      @backgroundSounds[sound] = new SoundObj
      mediator.std.xhrGet @PATH+sound+'.mp3', @bufferSounds, 'arraybuffer', sound, @backgroundSounds


  bufferSounds: (event) =>
    request = event.target
    buffer = @audioContext.createBuffer(request.response, false)
    request.additionalAttributes[1][request.additionalAttributes[0]].buffer = buffer

    console.log request.additionalAttributes[0] + '.mp3 loaded'
    @soundLoadCount++
    if @soundLoadCount == @soundCount
      console.log 'all sounds loaded'
      @publishEvent 'sound:loaded'


  playSound: (sound, list, volume, loops) =>
    sourceNode = @audioContext.createBufferSource()
    sourceNode.buffer = list[sound].buffer
    sourceNode.loop = loops

    sourceNode.gain.value = volume
    sourceNode.connect(@audioContext.destination)

    list[sound].sourceNode = sourceNode

    sourceNode.start(0)


  stop: (sound, list) =>
    @fade sound, list, 0
    setTimeout =>
      list[sound].sourceNode.stop(0)
      list[sound].isPlaying = false


  update: (PlayerPosition) =>
    #code


  # @todo start all backgroundSounds from the start
  startBackgroundSounds: =>
    for name, sound of @backgroundSounds
      @playSound name, @backgroundSounds, 0, true
      sound.isPlaying = true


  # maybe look for an optimization here
  updateBackgroundSounds: (PlayerPosition) =>
    @backgroundSoundsToPlay = []
    # TODO: not really elegant
    for sound in @soundMap[Math.floor(PlayerPosition.x/32)][Math.floor(PlayerPosition.y/32)]
      # sound.type is the name of the sound here
      if @backgroundSounds[sound.type].isPlaying
        @backgroundSounds[sound.type].isPlaying = true
      @fade sound.type, @backgroundSounds, sound.intensity/100
      @backgroundSoundsToPlay.push(sound.type)

    for name, sound of @backgroundSounds
      if sound.isPlaying && @backgroundSoundsToPlay.indexOf(name) == -1
        @fade name, @backgroundSounds, 0


  fade: (sound, list, volume) =>
    # exponentially approaching the target value <volume> at the given time with a rate <@FADE_TIME_INTERVAL>
    list[sound].sourceNode.gain.setTargetAtTime(volume, @audioContext.currentTime, @FADE_TIME_INTERVAL)
