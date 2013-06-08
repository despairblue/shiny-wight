Entity = require 'core/Entity'
Visual = require 'core/mixins/Visual'
Movable = require 'core/mixins/Movable'
Scriptable = require 'core/mixins/Scriptable'
mediator = require 'mediator'

module.exports = class Yeti extends Entity
  @include Scriptable
  @include Visual
  @include Movable

  mediator.factory['Yeti'] = this


  constructor: (owningLevel, object) ->
    object.ellipse = true

    oldWidth = object.width
    oldHeight = object.height

    object.width = oldWidth/2
    object.height = oldHeight/2

    super owningLevel, object

    @spriteState.viewDirection = 2

    @size.x = oldWidth
    @size.y = oldHeight


  onTouchBegin: (body, point) =>
    @spriteState.moving = true
    @makeMeStatic() if body.GetUserData()?.ent.name is 'Player'


  onTouch: (body, point, impulse) =>


  onTouchEnd: (body, point) =>
    @spriteState.moving = false
    @makeMeDynamic() if body.GetUserData()?.ent.name is 'Player'


  update: =>
    ###
      synchronize the visial position with the physical one
    ###
    super


  onAction: (player) =>
    mediator.dialogManager.showDialog {"text":"PIKACHU!!!","options":["Yeah...right."]}
