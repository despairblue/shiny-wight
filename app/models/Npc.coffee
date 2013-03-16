Person = require 'models/Person'

module.exports = class Npc extends Person
  # register entity
  mediator.factory['Npc'] = this