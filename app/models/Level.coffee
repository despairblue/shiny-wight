Model = require 'models/base/model'
mediator = require 'mediator'

module.exports = class Level extends Model

  soundList: {}
  backgroundSounds: {}

  # to check whether all sounds loaded
  soundLoadCount: 0
  soundCount: 0

  physicsMap: []

  gMap: null

  loadCompleted = false
