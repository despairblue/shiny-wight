Model = require 'models/base/model'
SoundObj = require 'models/SoundObj'
mediator = require 'mediator'

module.exports = class SoundManager extends Model

  audioContext: null

  PATH: 'sounds/'
  FADE_TIME_INTERVAL: 1


  initialize: =>
    super
    mediator.soundManager = @

    @audioContext = new webkitAudioContext()

    @subscribeEvent 'stopCurrentSounds', @stopAll


  load: (LEVEL) =>
    @subscribeEvent 'mapRendered:'+LEVEL, =>
      @initializeSoundMap(LEVEL, mediator.levels[LEVEL].gMap)
      mediator.std.xhrGet @PATH+LEVEL+'sounds.json', (data) =>
        mapSounds = JSON.parse data.target.responseText
        mediator.levels[LEVEL].soundCount =  mapSounds.sounds.length + mapSounds.backgroundSounds.length
        @loadSounds LEVEL, mapSounds


  initializeSoundMap: (LEVEL, map) =>
    currMapData = map.get 'currMapData'
    mediator.levels[LEVEL].soundMap = []
    for x in [0..map.numXTiles - 1]
      mediator.levels[LEVEL].soundMap[x] = for y in [0..map.numYTiles - 1]
        []

    for layer in currMapData.layers
      continue if layer.name isnt 'sound'

      for tileID, tileIndex in layer.data
        continue if tileID is 0

        x = (tileIndex % map.numXTiles)
        y = Math.floor(tileIndex / map.numXTiles)

        mediator.levels[LEVEL].soundMap[x][y].push(layer.properties)


  loadSounds: (LEVEL, mapSounds) =>
    for sound in mapSounds.sounds
      mediator.levels[LEVEL].soundList[sound] = new SoundObj
      mediator.std.xhrGet @PATH+sound+'.mp3', @bufferSounds, 'arraybuffer', sound, mediator.levels[LEVEL].soundList, LEVEL

    for sound in mapSounds.backgroundSounds
      mediator.levels[LEVEL].backgroundSounds[sound] = new SoundObj
      mediator.std.xhrGet @PATH+sound+'.mp3', @bufferSounds, 'arraybuffer', sound, mediator.levels[LEVEL].backgroundSounds, LEVEL


  bufferSounds: (event) =>
    request = event.target
    sound = request.additionalAttributes[0]
    list = request.additionalAttributes[1]
    LEVEL = request.additionalAttributes[2]

    buffer = @audioContext.createBuffer(request.response, false)
    list[sound].buffer = buffer

    mediator.levels[LEVEL].soundLoadCount++
    console.log sound+'.mp3 loaded'

    if mediator.levels[LEVEL].soundLoadCount == mediator.levels[LEVEL].soundCount
      console.log 'all sounds loaded'
      @publishEvent 'soundsLoaded:'+LEVEL


  playSound: (sound, list, volume, loops) =>
    sourceNode = @audioContext.createBufferSource()
    sourceNode.buffer = list[sound].buffer
    sourceNode.loop = loops

    sourceNode.gain.value = volume
    sourceNode.connect(@audioContext.destination)

    list[sound].sourceNode = sourceNode

    sourceNode.start(0)


  stop: (sound, list) =>
    setTimeout =>
      @fade sound, list, 0
    , @FADE_TIME_INTERVAL
    list[sound].sourceNode.stop(0)
    list[sound].isPlaying = false
    console.log sound+'.mp3 stopped'


  stopAll: =>
    for name, sound of mediator.levels[mediator.activeLevel].soundList
      @stop name, mediator.levels[mediator.activeLevel].soundList

    for name, sound of mediator.levels[mediator.activeLevel].backgroundSounds
      @stop name, mediator.levels[mediator.activeLevel].backgroundSounds


  # @todo start all backgroundSounds from the start
  startBackgroundSounds: () =>
    for name, sound of mediator.levels[mediator.activeLevel].backgroundSounds
      @playSound name, mediator.levels[mediator.activeLevel].backgroundSounds, 0, true
      sound.isPlaying = true


  # maybe look for an optimization here
  updateBackgroundSounds: (PlayerPosition) =>
    @backgroundSoundsToPlay = []
    # TODO: not really elegant
    for sound in mediator.levels[mediator.activeLevel].soundMap[Math.floor(PlayerPosition.x/32)][Math.floor(PlayerPosition.y/32)]
      # sound.type is the name of the sound here
      @fade sound.type, mediator.levels[mediator.activeLevel].backgroundSounds, sound.intensity/100
      @backgroundSoundsToPlay.push(sound.type)

    for name, sound of mediator.levels[mediator.activeLevel].backgroundSounds
      if @backgroundSoundsToPlay.indexOf(name) == -1
        @fade name, mediator.levels[mediator.activeLevel].backgroundSounds, 0


  fade: (sound, list, volume) =>
    # exponentially approaching the target value <volume> at the given time with a rate <@FADE_TIME_INTERVAL>
    list[sound].sourceNode.gain.setTargetAtTime(volume, @audioContext.currentTime, @FADE_TIME_INTERVAL)
