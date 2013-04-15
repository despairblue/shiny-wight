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
    @_visual_setUp()

    super x, y, width/2, height/2, owningLevel, settings
    @_visual_init()

    @size.x = width
    @size.y = height


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
    console.log @touchingEntity

  onTouchEnd: (otherBody, point) =>
    @touchingEntity = null
    console.log 'touch end'

  onAction: () =>
    @touchingEntity?.onAction @

  update: =>
    super


  # override from Entity class
  onPositionChange: ->
    mediator.soundManager.updateBackgroundSounds(@position)
