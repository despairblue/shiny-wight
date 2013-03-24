Model = require 'models/base/model'
mediator = require 'mediator'

module.exports = class SoundManager extends Model

  audioContext: null
  PATH: 'sounds/'
  soundList: []
  soundBuffers: {}
  backgroundSounds: {}


  initialize: () =>
    mediator.subscribe 'play', @playSound

    @audioContext = new webkitAudioContext()
    # soundList should be replaced with the mapSoundList of the actual lvl
    @soundList = ['defaultStep', 'dundundun', 'dummy']
    position =
      x : 1
      y : 1

    @backgroundSounds.push("dummy")
   # @backgroundSounds[]
    #["dummy"] = position
   # @backgroundSounds["dundundun"] = position
    @loadSounds()


  startBackgroundsSounds: =>
    for sound in @backgroundSounds
      sourceNode = @audioContext.createBufferSource()
      sourceNode.buffer = @soundBuffers[sound]
      sourceNode.loop = true

      pannerNode = @audioContext.createPanner()
      position = @backgroundSounds[sound]
      pannerNode.setPosition position.x, position.y, 0
      pannerNode.connect(@audioContext.destination)

      sourceNode.connect(pannerNode)
      sourceNode.noteOn(0)


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