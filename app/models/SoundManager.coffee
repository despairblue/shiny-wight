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

    console.log request.additionalAttributes[0] + '.mp3 loaded'
    @soundLoadCount++
    if @soundLoadCount == @soundCount
      console.log 'all sounds loaded'
      @publishEvent 'sound:loaded'


  playSound: (sound, volume) =>
    sourceNode = @audioContext.createBufferSource()
    sourceNode.buffer = @soundList[sound].buffer
    sourceNode.gain.value = volume
    sourceNode.connect(@audioContext.destination)

    sourceNode.start(0)
    @soundList[sound].sourceNode = sourceNode


  stop: (sound) =>
    @soundList[sound].sourceNode.stop(0)


  startSoundTheme: (sound, volume) =>
    sourceNode = @audioContext.createBufferSource()
    sourceNode.buffer = @soundList[sound].buffer
    sourceNode.loop = true
    sourceNode.gain.value = volume

    sourceNode.connect(@audioContext.destination)

    sourceNode.start(0)
    @soundList[sound].sourceNode = sourceNode


  startBackgroundsSounds: =>
    for sound of @backgroundSounds
      sourceNode = @audioContext.createBufferSource()
      sourceNode.buffer = @soundList[sound].buffer
      sourceNode.loop = true
      sourceNode.connect(@audioContext.destination)
      sourceNode.start(0)
      @soundList[sound].sourceNode = sourceNode


  update: (PlayerPosition) =>
    # soundTile the player stands on
    # welche werte sind auf der karte -> werte liste
    #
    @audioContext.listener.setPosition PlayerPosition.x, PlayerPosition.y, 0
