Model     = require 'models/base/model'
SoundObj  = require 'core/SoundObj'
mediator  = require 'mediator'

module.exports = class SoundManager extends Model

  ###
  Initialize Soundmanager.
  Create a new audio context and bind soundManager to mediator
  ###
  initialize: =>
    super
    mediator.soundManager = @

    # deactivate sound if not on chrome
    if webkitAudioContext?
      @audioContext = new webkitAudioContext()
    else
      mediator.playWithSounds = false
    @globalSoundList = {}
    @lastLevelTheme = ""


  ###
  @param [Object]
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


  ###
  @param [Array]
  @param [function]
  Load sounds
  ###
  loadSounds: (mapSounds, callback) =>
    @soundCount = mapSounds.sounds.length + mapSounds.backgroundSounds.length + 1

    for sound in mapSounds.sounds
      if not @globalSoundList[sound]?
        @globalSoundList[sound] = new SoundObj
        mediator.std.xhrGet mapSounds.prefix+sound, @bufferSounds, 'arraybuffer', sound, callback
      else callback()

    for sound in mapSounds.backgroundSounds
      if not @globalSoundList[sound]?
        @globalSoundList[sound] = new SoundObj
        mediator.std.xhrGet mapSounds.prefix+sound, @bufferSounds, 'arraybuffer', sound, callback
      else callback()

    if not @globalSoundList[mapSounds.theme]?
      @globalSoundList[mapSounds.theme] = new SoundObj
      mediator.std.xhrGet mapSounds.prefix+mapSounds.theme, @bufferSounds, 'arraybuffer', mapSounds.theme, callback
    else callback()


  ###
  @param [xhrGethttp-request]
  Buffer the sound we just got from xhrGet request and put it into the corresponding SourceNode in the audio context
  @note later trigger the observer event for 'all sounds loaded'
  ###
  bufferSounds: (event) =>
    request = event.target
    sound = request.additionalAttributes[0]
    callback = request.additionalAttributes[1]

    buffer = @audioContext.decodeAudioData request.response, (buffer) =>

      @globalSoundList[sound].buffer = buffer

      console.debug '@s loaded', sound

      callback?()


  ###
  @param [String]
  @param [Double]
  @param [Bool]
  Play sound of list with volume and loop
  ###
  playSound: (sound, volume, loops) =>
    if @globalSoundList[sound].isPlaying != true
      sourceNode            = @audioContext.createBufferSource()
      sourceNode.buffer     = @globalSoundList[sound].buffer
      sourceNode.loop       = loops
      sourceNode.gain.value = volume

      sourceNode.connect(@audioContext.destination)

      @globalSoundList[sound].sourceNode = sourceNode

      sourceNode.start(0)
      @globalSoundList[sound].isPlaying = true
    else @fade sound, volume, 0


  ###
  @param [String]
  Stop sound
  ###
  stop: (sound) =>
    if @globalSoundList[sound].isPlaying
      @globalSoundList[sound].sourceNode.stop(@audioContext.currentTime)
      @globalSoundList[sound].isPlaying = false
      console.debug '@s.mp3 stopped', sound


  ###
  @param [Object]
  Stop all with config specified sounds in active level
  ###
  stopAll: (config) =>
    soundsToStop = []

    if config?.themeSound
      soundsToStop.push mediator.getActiveLevel().themeSound
    else
      @lastLevelTheme = mediator.getActiveLevel().themeSound

    if config?.backgroundSounds
      for sound in mediator.getActiveLevel().backgroundSoundList
        soundsToStop.push sound

    if config?.sounds
      for sound in mediator.getActiveLevel().mapSoundList
        soundsToStop.push sound

    for name, sound of @globalSoundList
      if (soundsToStop.indexOf name) isnt -1
        @stop name


  ###
  Start all background sounds in backgroundSoundList of active level with gain = 0, i.e. muted
  ###
  startBackgroundSounds: () =>
    for sound in mediator.getActiveLevel().backgroundSoundList
      @playSound sound, 0, true


  ###
  Start theme of level
  Fade the if it stays the same on level change
  ###
  startThemeSound: () =>
    theme = mediator.getActiveLevel().themeSound
    intensity = mediator.getActiveLevel().themeIntensity

    if @lastLevelTheme == theme
      @fade theme, intensity, 0
    else
      @stop @lastLevelTheme if @globalSoundList[@lastLevelTheme]?
      @playSound theme, intensity, true


  ###
  @param [Object]
  Look for backgroundSounds to play on the player position on the soundMap and update their gain
  @todo maybe look for an optimization here
  ###
  updateBackgroundSounds: (PlayerPosition) =>
    @backgroundSoundsToPlay = []
    # TODO: not really elegant
    lvl = mediator.getActiveLevel()
    for sound in lvl.soundMap[Math.floor(PlayerPosition.x/32)][Math.floor(PlayerPosition.y/32)]
      # sound.type is the name of the sound here
      @fade sound.type+'.mp3', sound.intensity/100, 1
      @backgroundSoundsToPlay.push(sound.type+'.mp3')

    for sound in lvl.backgroundSoundList
      if @backgroundSoundsToPlay.indexOf(sound) == -1
        @fade sound, 0, 1


  ###
  @param [String]
  @param [Double]
  @param [Double]
  Fade sound to volume
  ###
  fade: (sound, volume, interval) =>
    # exponentially approaching the target value <volume> at the given time with a rate <interval>
    @globalSoundList[sound].sourceNode.gain.setTargetAtTime(volume, @audioContext.currentTime, interval)


  startAll: =>
    @startThemeSound()
    @startBackgroundSounds()
    @updateBackgroundSounds(mediator.getActiveLevel().player.position)
