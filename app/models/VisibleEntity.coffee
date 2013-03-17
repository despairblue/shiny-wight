Entity = require 'models/Entity'

module.exports = class VisibleEntity extends Entity

  tileSet:
    image: ""
    imageheight: 0
    imagewidth: 0
    tileheight: 0
    tilewidth: 0
  # order of tiles that form the animation
  animationState: 0


  getSprite: =>
    # get sprite

  load: ->

    tileSet = @get 'tileSet'

    img = new Image()
    img.src = tileSet.image

    @set 'atlas':img

  render: (ctx, cx, cy) ->
    # render method to be overloaded