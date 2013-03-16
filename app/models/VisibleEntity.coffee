Entity = require 'models/Entity'

mudule.exports = class VisibleEntity extends Entity
  defaults:
    tileSet:
      image: ""
      imageheight: 0
      imagewidth: 0
      name: ""
      tileheight: 0
      tilewidth: 0

  getSprite: =>
    # get sprite
