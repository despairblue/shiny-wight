Model = require 'models/base/model'
SoundObj = require 'models/SoundObj'
mediator = require 'mediator'

module.exports = class SoundManager extends Model

  audioContext: null
  soundList: {}
  backgroundSounds: {}

  PATH: 'sounds/'

  initialize: () =>
    mediator.subscribe 'play', @playSound
    mediator.subscribe 'stop', @stop

    @audioContext = new webkitAudioContext()
    # soundList should be replaced with the mapSoundList of the actual lvl
    @soundList['defaultStep'] = new SoundObj()
    @soundList['dundundun'] = new SoundObj()
    @soundList['dummy'] = new SoundObj()

    @loadSounds()

    #hardcoded backgroundSounds, will be automated later

    @backgroundSounds["dummy"] = x:1, y:1
    @backgroundSounds["dundundun"] = x:10, y:10


  stop: (sound) =>
    @soundList[sound].sourceNode.noteOff(0)
    @soundList[sound].isLooping = false



  startBackgroundsSounds: =>
    for sound of @backgroundSounds
      continue if @soundList[sound].isLooping
      sourceNode = @audioContext.createBufferSource()
      sourceNode.buffer = @soundList[sound].buffer
      sourceNode.loop = true

      pannerNode = @audioContext.createPanner()
      pannerNode.rolloffFactor = 1
      position = @backgroundSounds[sound]
      pannerNode.setPosition position.x, position.y, 0
      pannerNode.connect(@audioContext.destination)

      sourceNode.connect(pannerNode)
      sourceNode.noteOn(0)
      @soundList[sound].sourceNode = sourceNode
      @soundList[sound].isLooping = true


  playSound: (sound, volume) =>
    if @soundList[sound].isLooping
      return
    sourceNode = @audioContext.createBufferSource()
    sourceNode.buffer = @soundList[sound].buffer
    sourceNode.gain.value = volume
    sourceNode.connect(@audioContext.destination)

    sourceNode.noteOn(0)
    @soundList[sound].sourceNode = sourceNode

  loadSounds: () =>
    for sound of @soundList
      request = new XMLHttpRequest()
      request.soundName = @soundList[sound].name = sound
      request.open('GET', @PATH+request.soundName+'.mp3', true)
      request.responseType = 'arraybuffer'

      request.addEventListener('loadend', @bufferSound, false)

      request.send()

  bufferSound: (event) =>
    request = event.target
    buffer = @audioContext.createBuffer(request.response, false)
    @soundList[request.soundName].buffer = buffer

  update: (PlayerPosition) =>
    @audioContext.listener.setPosition PlayerPosition.x, PlayerPosition.y, 0
