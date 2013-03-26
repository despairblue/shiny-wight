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


  initialize: () =>
    mediator.subscribe 'play', @playSound
    mediator.subscribe 'stop', @stop

    @audioContext = new webkitAudioContext()

    # should be called in home-page-view later
    @load("sounds/level1sounds.json")

    #hardcoded backgroundSounds, will be automated later
    ###
    @backgroundSounds['fire'] = x:9, y:8
    @backgroundSounds['wood'] = x:6, y:0
    @backgroundSounds['water'] = x:6, y:12
    ###


  load: (level) =>
    mediator.std.xhrGet level, (data) =>
      mapSounds = JSON.parse data.target.responseText
      @soundCount =  mapSounds.sounds.length
      @loadSounds mapSounds


  loadSounds: (mapSounds) =>
    for sound in mapSounds.sounds
      @soundList[sound] = new SoundObj
      mediator.std.xhrGet @PATH+sound+'.mp3', @bufferSounds, 'arraybuffer', sound


  bufferSounds: (event) =>
    request = event.target
    buffer = @audioContext.createBuffer(request.response, false)
    @soundList[request.additionalAttributes[0]].buffer = buffer

    console.log request.soundName + '.mp3 loaded'
    @soundLoadCount++
    if @soundLoadCount == @soundCount
      console.log 'all sounds loaded'
      @publishEvent 'sound:loaded'


  playSound: (sound, volume) =>
    sourceNode = @audioContext.createBufferSource()
    sourceNode.buffer = @soundList[sound].buffer
    sourceNode.gain.value = volume
    sourceNode.connect(@audioContext.destination)

    sourceNode.noteOn(0)
    @soundList[sound].sourceNode = sourceNode


  stop: (sound) =>
    @soundList[sound].sourceNode.noteOff(0)


  startSoundTheme: (sound, volume) =>
    sourceNode = @audioContext.createBufferSource()
    sourceNode.buffer = @soundList[sound].buffer
    sourceNode.loop = true
    sourceNode.gain.value = volume

    sourceNode.connect(@audioContext.destination)
    sourceNode.noteOn(0)
    @soundList[sound].sourceNode = sourceNode


  startBackgroundsSounds: =>
    for sound of @backgroundSounds
      sourceNode = @audioContext.createBufferSource()
      sourceNode.buffer = @soundList[sound].buffer
      sourceNode.loop = true

      pannerNode = @audioContext.createPanner()
      pannerNode.rolloffFactor = 1
      #pannerNode.PanningModelType = "equalpower"
      position = @backgroundSounds[sound]
      pannerNode.setPosition position.x, position.y, 0
      pannerNode.connect(@audioContext.destination)

      sourceNode.connect(pannerNode)
      sourceNode.noteOn(0)
      @soundList[sound].sourceNode = sourceNode


  update: (PlayerPosition) =>
    @audioContext.listener.setPosition PlayerPosition.x, PlayerPosition.y, 0
