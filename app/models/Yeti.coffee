Entity = require 'core/Entity'
Visual = require 'core/mixins/Visual'
Movable = require 'core/mixins/Movable'
mediator = require 'mediator'

module.exports = class Yeti extends Entity
  @include Visual
  @include Movable

  mediator.factory['Yeti'] = this


  constructor: (x, y, width, height, owningLevel, settings) ->
    settings.ellipse = true
    @_visual_setUp()
    @_movable_setUp()

    super x, y, width/2, height/2, owningLevel, settings
    @_visual_init()
    @_movable_init()

    @spriteState.viewDirection = 2

    @size.x = width
    @size.y = height

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
