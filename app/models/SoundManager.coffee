Model = require 'models/base/model'
SoundObj = require 'models/SoundObj'
mediator = require 'mediator'

module.exports = class SoundManager extends Model

  audioContext: null

  PATH: 'sounds/'
  FADE_TIME_INTERVAL: 1

  ###
  Initialize Soundmanager.
  Create a new audio context and bind soundManager to mediator
  ###
  initialize: =>
    super
    mediator.soundManager = @

    @audioContext = new webkitAudioContext()

    @subscribeEvent 'stopCurrentSounds', @stopAll

  ###
  @param [String]
  @param [map]
  Initializes soundMap for backgroundSounds
  ###
  getSoundMap: (map) =>
    soundMap = []
    for x in [0..map.width - 1]
      soundMap[x] = for y in [0..map.height - 1]
        []

    for layer in map.layers
      continue if layer.name isnt 'sound'

      for tileID, tileIndex in layer.data
        continue if tileID is 0

        x = (tileIndex % map.width)
        y = Math.floor(tileIndex / map.width)

        soundMap[x][y].push(layer.properties)

    return soundMap


  loadSounds: (mapSounds, callback) =>
    @soundCount = mapSounds.sounds.length + 1 + mapSounds.backgroundSounds.length
    @soundList = {}
    @backgroundSounds = {}
    @themeSound = {}

    for sound in mapSounds.sounds
      @soundList[sound] = new SoundObj
      mediator.std.xhrGet mapSounds.prefix+sound, @bufferSounds, 'arraybuffer', sound, @soundList, callback

    for sound in mapSounds.backgroundSounds
      @backgroundSounds[sound] = new SoundObj
      mediator.std.xhrGet mapSounds.prefix+sound, @bufferSounds, 'arraybuffer', sound, @backgroundSounds, callback

    @themeSound[mapSounds.theme] = new SoundObj
    mediator.std.xhrGet mapSounds.prefix+mapSounds.theme, @bufferSounds, 'arraybuffer', mapSounds.theme, @themeSound, callback


  ###
  @param [xhrGethttp-request]
  Buffer the sound we just got from xhrGet request and put it into the corresponding SourceNode in the audio context
  @note later trigger the observer event for 'all sounds loaded'
  ###
  bufferSounds: (event) =>
    request = event.target
    sound = request.additionalAttributes[0]
    list = request.additionalAttributes[1]
    callback = request.additionalAttributes[2]

    buffer = @audioContext.createBuffer(request.response, false)
    list[sound].buffer = buffer

    console.log sound+' loaded' if debug

    @soundCount--
    if @soundCount <= 0
      callback(@soundList, @backgroundSounds, @themeSound)

  ###
  @param [String]
  @param [Object]
  @param [Double]
  @param [Bool]
  Play sound of list with volume and loop
  ###
  playSound: (sound, list, volume, loops) =>
    sourceNode = @audioContext.createBufferSource()
    sourceNode.buffer = list[sound].buffer
    sourceNode.loop = loops

    sourceNode.gain.value = volume
    sourceNode.connect(@audioContext.destination)

    list[sound].sourceNode = sourceNode

    sourceNode.start(0)

  ###
  @param [String]
  @param [Object]
  Stop sound in list
  ###
  stop: (sound, list) =>
    list[sound].sourceNode.stop(@audioContext.currentTime)
    list[sound].isPlaying = false
    console.log sound+'.mp3 stopped' if debug

  ###
  Stop all sounds in active level
  ###
  stopAll: =>
    try
      for name, sound of mediator.getActiveLevel().soundList
        @stop name, mediator.getActiveLevel().soundList

      for name, sound of mediator.getActiveLevel().backgroundSoundList
        @stop name, mediator.getActiveLevel().backgroundSoundList

      for name, sound of mediator.getActiveLevel().themeSound
        @stop name, mediator.getActiveLevel().themeSound


      #@stop mediator.activeLevel+'theme.mp3', mediator.getActiveLevel().themeSound

    catch e
      console.log e.toString() if debug


  ###
  Start all background sounds in backgroundSound list of active level with gain = 0, i.e. muted
  ###
  startBackgroundSounds: () =>
    for name, sound of mediator.getActiveLevel().backgroundSoundList
      @playSound name, mediator.getActiveLevel().backgroundSoundList, 0, true
      sound.isPlaying = true

  startThemeSound: () =>
    for name, sound of mediator.getActiveLevel().themeSound
      @playSound name, mediator.getActiveLevel().themeSound, 1, true
      sound.isPlaying = true

  ###
  @param [Object]
  Look for backgroundSounds to play on the player position on the soundMap and update their gain
  @todo maybe look for an optimization here
  ###
  updateBackgroundSounds: (PlayerPosition) =>
    @backgroundSoundsToPlay = []
    # TODO: not really elegant
    for sound in mediator.getActiveLevel().soundMap[Math.floor(PlayerPosition.x/32)][Math.floor(PlayerPosition.y/32)]
      # sound.type is the name of the sound here
      @fade sound.type+'.mp3', mediator.getActiveLevel().backgroundSoundList, sound.intensity/100
      @backgroundSoundsToPlay.push(sound.type+'.mp3')

    for name, sound of mediator.getActiveLevel().backgroundSoundList
      if @backgroundSoundsToPlay.indexOf(name) == -1
        @fade name, mediator.getActiveLevel().backgroundSoundList, 0

  ###
  @param [String]
  @param [Object]
  @param [Double]
  Fade sound in list to gain
  ###
  fade: (sound, list, volume) =>
    # exponentially approaching the target value <volume> at the given time with a rate <@FADE_TIME_INTERVAL>
    list[sound].sourceNode.gain.setTargetAtTime(volume, @audioContext.currentTime, @FADE_TIME_INTERVAL)


  startAll: =>
    @startThemeSound()
    @startBackgroundSounds()
    @updateBackgroundSounds(mediator.getActiveLevel().player.position)

