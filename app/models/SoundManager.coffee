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


  initialize: =>
    super
    mediator.soundManager = @
    mediator.subscribe 'play', @playSound
    mediator.subscribe 'stop', @stop

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
    sourceNode.gain.value = volume
    sourceNode.loop = loops
    sourceNode.connect(@audioContext.destination)

    sourceNode.start(0)
    list[sound].sourceNode = sourceNode


  stop: (sound, list) =>
    list[sound].sourceNode.stop(0)
    list[sound].isPlaying = false


  update: (PlayerPosition) =>
    #code


  updateBackgroundSounds: (PlayerPosition) =>
    @backgroundSoundsToPlay = []
    for sound in @soundMap[PlayerPosition.x][PlayerPosition.y]
      # sound.type is the name of the sound here
      if @backgroundSounds[sound.type].isPlaying
        @backgroundSounds[sound.type].sourceNode.gain.value = sound.intensity/100
      else
        @playSound sound.type, @backgroundSounds, sound.intensity/100, true
        @backgroundSounds[sound.type].isPlaying = true
      @backgroundSoundsToPlay.push(sound.type)
    for key, sound of @backgroundSounds
      if sound.isPlaying && @backgroundSoundsToPlay.indexOf(key) == -1
        sound.sourceNode.gain.value = 0
