Model = require 'models/base/model'
mediator = require 'mediator'

module.exports = class SoundObj extends Model

  sourceNode: null
  gainNode: null
  buffer: null
  isPlaying: false
