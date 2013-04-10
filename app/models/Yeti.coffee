Entity = require 'core/Entity'
Visual = require 'core/mixins/Visual'
mediator = require 'mediator'

module.exports = class Yeti extends Entity
  @include Visual

  mediator.factory['Yeti'] = this


  constructor: (x, y, width, height, owningLevel, settings) ->
    settings.ellipse = true

    super x, y, width/2, height/2, owningLevel, settings

    @_initVisual()

    @size.x = width
    @size.y = height

    @spriteState.creationTime = Date.now()
    ###
      TODO: uncomment properties if needed
    ###
    ###
      Is the object Static or Dynamic?
    ###
    # settings.physicsType = 'static'
    settings.physicsType = 'dynamic'


    ###
      If the entity is a Sensor it means that the player can walk through it
    ###
    #settings.isSensor    = true

    @physBody.SetLinearVelocity(new @level.physicsManager.Vec2(0, 0))


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
