Model = require 'models/base/model'
mediator = require 'mediator'

module.exports = class SoundObj extends Model

  name = ""
  sourceNode = null
  isLooping = false
  buffer = null
