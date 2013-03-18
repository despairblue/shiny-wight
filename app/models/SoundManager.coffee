Model = require 'models/base/model'
mediator = require 'mediator'

module.exports = class SoundManager extends Model


  initialize: () =>
    createjs.Sound.addEventListener "loadComplete", createjs.proxy(@playSound, @)
    createjs.Sound.registerSound 'sounds/dundundun.mp3', 'rainbow'
    mediator.subscribe 'play', @playSound

  playSound: =>
    instance = createjs.Sound.play 'rainbow'
    # instance.addEventListener "complete", createjs.proxy(this.handleComplete, this)
    instance.setVolume 0.5
