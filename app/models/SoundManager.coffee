Model = require 'models/base/model'
mediator = require 'mediator'

module.exports = class SoundManager extends Model

  audioContext: null
  PATH: 'sounds/'
  soundList: []
  soundBuffers: {}


  initialize: () =>
    mediator.subscribe 'play', @playSound

    @audioContext = new webkitAudioContext()
    # soundList should be replaced with the mapSoundList of the actual lvl
    @soundList = ['defaultStep', 'dundundun']
    @loadSounds()

  playSound: (sound, volume) =>
    sourceNode = @audioContext.createBufferSource()
    sourceNode.buffer = @soundBuffers[sound]
    sourceNode.connect(@audioContext.destination)
    sourceNode.gain.value = volume
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