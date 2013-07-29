Event = require 'entities/Event'
mediator = require 'mediator'
story = require 'story/level1'

module.exports = class Level1Event1 extends Event
  constructor: (owningLevel, object) ->
    super owningLevel, object

    @addOneTimeListener 'touchBegin', @_spawnYetis
    @addOneTimeListener 'touchEnd', @_activateYetis

  ###
  This event handler is going to be called every time another
  entity starts or ends touching it, as well as continuously if
  an entity keeps touching it.
  @param [event] Event object.
  @see #constructor
  ###
  _spawnYetis: (event) =>
    that = @

    that.level.addTask ->
      jt = _.clone ss =
        name: 'Yeti'
        type: 'Yeti'
        x: 16*32
        y: 16
        width: 32
        height: 32
        properties: {}

      ss.x = 17*32

      that.jt = that.level.addEntity jt
      that.ss = that.level.addEntity ss

      # TODO: the soundManager should take care of this!
      if mediator.playWithSounds
        mediator.soundManager.stopAll config =
          themeSound: true
          backgroundSounds: true

        mediator.soundManager.playSound that.level.manifest.sounds.sounds[0], 1, true


  ###
  This event handler is going to be called only once, on the first
  update.
  @param [event] Event object
  @see #constructor
  ###
  _activateYetis: (event) =>
    that = @
    body = event.arguments[0]
    player = body.GetUserData().ent
    jt = that.jt
    ss = that.ss
    dm = mediator.dialogManager

    dm.hideDialog()

    jt.blockInput().movable.moveDown(150).moveLeft(60)
    jt.scriptable.addTask =>
      dm.showDialog story[1], (result) =>
        jt.scriptable.addTask =>
          dm.showDialog story[2], =>
            ss.movable.moveDown(150).moveLeft(90)
            jt.movable.moveDown(90).moveLeft(30).owner.scriptable.addTask =>


              dm.showDialog story[3], =>
                jt.scriptable.addTask =>

                  dm.showDialog story[4], =>
                    jt.scriptable.addTask =>

                      dm.showDialog story[5], =>
                        jt.scriptable.addTask =>

                          dm.showDialog story[6], =>
                            # [Black, Smashing Noises, Wilhelms Scream]
                            mediator.configurationManager.configure player, 'PlayerSkeleton'

                            jt.movable.moveRight(80).moveUp(250)
                            ss.movable.moveRight(60).moveUp(250)

                            jt.scriptable.addTask =>
                              ss.kill()
                              jt.kill()

                              dm.showDialog story[7], =>
                                that.unblockInput()
