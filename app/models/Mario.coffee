Entity = require 'core/Entity'
Visual = require 'core/mixins/Visual'
mediator = require 'mediator'

module.exports = class Mario extends Entity
  @include Visual
  # register entity
  mediator.factory['Mario'] = this


  constructor: (x, y, width, height, owningLevel, settings) ->
    # settings.ellipse = true
    settings.physicsType = 'static'
    @_visual_setUp()

    super x, y, width, height, owningLevel, settings
    @_visual_init()

    @size.x = width
    @size.y = height


  update: =>
    super
