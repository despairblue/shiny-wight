VisibleEntity = require 'models/VisibleEntity'

module.exports = class LivingEntity extends VisibleEntity
defaults:
  level: 0
  hp: 0
  viewDirection: 0 # enum{up, down, left, right} ?

die: =>
