Entity = require 'core/Entity'
Visual = require 'core/mixins/Visual'
mediator = require 'mediator'

###
The Player
###
module.exports = class Player extends Entity
  @include Visual
  # register entity
  mediator.factory['Player'] = this


  constructor: (x, y, width, height, owningLevel, settings) ->
    settings.ellipse = true

    super x, y, width/2, height/2, owningLevel, settings
    @_initVisual()

    @tileSet.image = 'atlases/warrior_m.png'
    @tileSet.tilesX = 3
    @tileSet.tilesY = 4
    @tileSet.tileheight = 32
    @tileSet.tilewidth = 32
    @tileSet.offset =
      x: 16
      y: 24

    @size.x = width
    @size.y = height


  kill: =>


  onTouch: (otherBody, point, impulse) =>
    return false if not @physBody?
    return false if not otherBody.GetUserData()?

    physOwner = otherBody.GetUserData().ent

    if physOwner?.killed
      return false
    else
      # do smth

  onTouchBegin: (otherBody, point) =>
    @touchingEntity = otherBody.GetUserData()?.ent

  onTouchEnd: (otherBody, point) =>
    @touchingEntity = null

  onAction: () =>
    @touchingEntity?.onAction @

  update: =>
    super


  # override from Entity class
  onPositionChange: ->
    mediator.soundManager.updateBackgroundSounds(@position)
