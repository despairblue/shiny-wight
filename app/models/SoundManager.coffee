Model = require 'models/base/model'
mediator = require 'mediator'

module.exports = class SoundManager extends Model

  audioContext: null
  PATH: 'sounds/'
  soundList: []
  soundBuffers: {}
  backgroundSounds: {}
  playingSounds: {}


  initialize: () =>
    mediator.subscribe 'play', @playSound
    mediator.subscribe 'stop', @stop

    @audioContext = new webkitAudioContext()
    # soundList should be replaced with the mapSoundList of the actual lvl
    @soundList = ['defaultStep', 'dundundun', 'dummy']
    @loadSounds()

    #hardcoded backgroundSounds, will be automated later

    position =
      x : 1
      y : 1

    @backgroundSounds["dummy"] = position

    position =
      x : 10
      y : 10

    @backgroundSounds["dundundun"] = position


  stop: (sound) =>
    @playingSounds[sound].noteOff(0)


  startBackgroundsSounds: =>
    for sound of @backgroundSounds
      sourceNode = @audioContext.createBufferSource()
      sourceNode.buffer = @soundBuffers[sound]
      sourceNode.loop = true

      pannerNode = @audioContext.createPanner()
      pannerNode.rolloffFactor = 1
      position = @backgroundSounds[sound]
      pannerNode.setPosition position.x, position.y, 0
      pannerNode.connect(@audioContext.destination)

      sourceNode.connect(pannerNode)
      sourceNode.noteOn(0)
      @playingSounds[sound] = sourceNode


  playSound: (sound, volume) =>
    sourceNode = @audioContext.createBufferSource()
    sourceNode.buffer = @soundBuffers[sound]
    sourceNode.gain.value = volume
    sourceNode.connect(@audioContext.destination)

    sourceNode.noteOn(0)

  loadSounds: () =>
    for sound in @soundList
      request = new XMLHttpRequest()
      request.soundName = sound
      request.open('GET', @PATH+request.soundName+'.mp3', true)
      request.responseType = 'arraybuffer'

      request.addEventListener('loadend', @bufferSound, false)

      request.send()

  bufferSound: (event) =>
    request = event.target
    buffer = @audioContext.createBuffer(request.response, false)
    @soundBuffers[request.soundName] = buffer

  update: (PlayerPosition) =>
    @audioContext.listener.setPosition PlayerPosition.x, PlayerPosition.y, 0