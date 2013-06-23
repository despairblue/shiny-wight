Entity = require 'core/Entity'
Visual = require 'components/Visual'
Movable = require 'components/Movable'
Scriptable = require 'components/Scriptable'
mediator = require 'mediator'

module.exports = class Yeti extends Entity
  mediator.factory['Yeti'] = this


  constructor: (owningLevel, object) ->
    object.ellipse = true

    oldWidth = object.width
    oldHeight = object.height

    object.width = oldWidth/2
    object.height = oldHeight/2

    super owningLevel, object
    @scriptable = new Scriptable @
    @visual     = new Visual @
    @movable    = new Movable @


    @visual.spriteState.viewDirection = 2

    @size.x = oldWidth
    @size.y = oldHeight


  onTouchBegin: (body, point) =>
    @visual.spriteState.moving = true
    @makeMeStatic() if body.GetUserData()?.ent.name is 'Player'


  onTouch: (body, point, impulse) =>


  onTouchEnd: (body, point) =>
    @visual.spriteState.moving = false
    @makeMeDynamic() if body.GetUserData()?.ent.name is 'Player'


  update: =>
    ###
      synchronize the visial position with the physical one
    ###
    super


  onAction: (player) =>
    mediator.dialogManager.showDialog {"text":"PIKACHU!!!","options":["Yeah...right."]}
