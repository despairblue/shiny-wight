Event = require 'entities/Event'
mediator = Chaplin.mediator
story = require 'story/level1'
Result = require 'core/Result'

module.exports = class Level1Event1 extends Event
  constructor: (owningLevel, object) ->
    super owningLevel, object

    @dm = mediator.dialogManager

    # @addOneTimeListener 'touchBegin', @_spawnYetis
    @addOneTimeListener 'touchBegin', =>
      @level.addTask @_spawnYetis
    @addOneTimeListener 'touchEnd', @_activateYetis2


  ###
  This event handler is going to be called every time another
  entity starts or ends touching it, as well as continuously if
  an entity keeps touching it.
  @param [event] Event object.
  @see #constructor
  ###
  _spawnYetis: (event) =>
    jt = _.clone ss =
      name: 'Yeti'
      type: 'Yeti'
      x: 16*32
      y: 16
      width: 32
      height: 32
      properties: {}

    ss.x = 17*32

    @jt = @level.addEntity jt
    @ss = @level.addEntity ss

    # TODO: the soundManager should take care of this!
    if mediator.playWithSounds
      mediator.soundManager.stopAll config =
        themeSound: true
        backgroundSounds: true

      mediator.soundManager.playSound @level.manifest.sounds.sounds[0], 1, true

    return new Result true


  ###
  This event handler is going to be called only once, on the first
  update.
  @param [event] Event object
  @see #constructor
  ###
  _activateYetis: (event) =>
    body = event.arguments[0]
    @player = body.GetUserData().ent
    @jt = @jt
    @ss = @ss

    @dm.hideDialog()

    @jt.blockInput().
    then(=>
      @jt.moveDown 150 ).
    then(=>
      @jt.moveLeft 60 ).
    then(=>
      @dm.showDialog story[1] ).
    then(=>
      @dm.showDialog(story[2]) ).
    then(=>
      Q.all([
        (@ss.moveDown 150 ).
        then(=>
          @ss.moveLeft 90 )
      ,
        (@jt.moveDown 90 ).
        then(=>
          @jt.moveLeft 30 )
      ]) ).
    then(=>
      @dm.showDialog story[3] ).
    then(=>
      @dm.showDialog story[4] ).
    then(=>
      @dm.showDialog story[5] ).
    then(=>
      @dm.showDialog story[6] ).
    then(=>
      mediator.configurationManager.configure @player, 'PlayerSkeleton'
      Q.all([
        (@jt.moveRight 80 ).
        then(=>
          @jt.moveUp 250 )
      ,
        (@ss.moveRight 60 ).
        then(=>
          @ss.moveUp 165 )
      ]) ).
    then(=>
      Q.all([
        @ss.kill()
      ,
        @jt.kill()
      ]) ).
    then(=>
      @dm.showDialog story[7] ).
    then(
      @unblockInput )
    # done()


  ###
  This event handler is going to be called only once, on the first
  update.
  @param [event] Event object
  @see #constructor
  ###
  _activateYetis2: (event) =>
    body = event.arguments[0]
    @player = body.GetUserData().ent

    @jt.addScripts [
      @dm.hideDialog
      @jt.blockInput
      [ @jt.moveDown, 150 ]
      [ @jt.moveLeft, 60 ]
      [ @dm.showDialog, story[1] ]
      [ @dm.showDialog, story[2] ]
      [
        [
          [ @ss.moveDown, 150 ]
          [ @ss.moveLeft, 50 ]
        ]
        [
          [ @ss.moveLeft, 40 ]
        ]
        [
          [ @jt.moveDown, 90 ]
          [ @jt.moveLeft, 30 ]
        ]
      ]
      [ @dm.showDialog, story[3] ]
      [ @dm.showDialog, story[4] ]
      [ @dm.showDialog, story[5] ]
      [ @dm.showDialog, story[6] ]
      =>
        mediator.configurationManager.promisedConfigure @player, 'PlayerSkeleton'
      [
        [
          [ @jt.moveRight, 80 ]
          [ @jt.moveUp, 250 ]
        ]
        [
          [ @ss.moveRight, 60 ]
          [ @ss.moveUp, 165 ]
        ]
      ]
      [ @ss.kill ]
      [ @jt.kill ]
      [ @dm.showDialog, story[7] ]
      [ @unblockInput ]
    ]
