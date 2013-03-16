Entity = require 'models/Entity'

module.exports = class VisibleEntity extends Entity
  defaults:
    tileSet:
      image: ""
      imageheight: 0
      imagewidth: 0
      name: ""
      tileheight: 0
      tilewidth: 0
      moveState: [0, 1, 2, 1]

  getSprite: =>
    # get sprite

  load: ->

    tileSet = @get 'tileSet'

    img = new Image()
    img.src = tileSet.image

    @set 'atlas':img

  render: (ctx, cx, cy) ->
    # render method to be overloaded