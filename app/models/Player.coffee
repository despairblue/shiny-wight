Entity = require 'core/Entity'
Visual = require 'core/components/Visual'
mediator = require 'mediator'

###
The Player
###
module.exports = class Player extends Entity
  # register entity
  mediator.factory['Player'] = this


  constructor: (owningLevel, object) ->
    object.properties.ellipse = true

    oldWidth = object.width
    oldHeight = object.height

    object.width = oldWidth/2
    object.height = oldHeight/2

    super owningLevel, object
    @visual = new Visual @

    @size.x = oldWidth
    @size.y = oldHeight


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
