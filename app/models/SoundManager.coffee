Model     = require 'models/base/model'
SoundObj  = require 'models/SoundObj'
mediator  = require 'mediator'

module.exports = class SoundManager extends Model

  audioContext: null

  PATH: 'sounds/'
  FADE_BACKGROUND_INTERVAL: 1
  FADE_THEME_INTERVAL: 0.3


  ###
  Initialize Soundmanager.
  Create a new audio context and bind soundManager to mediator
  ###
  initialize: =>
    super
    mediator.soundManager = @

    @audioContext = new webkitAudioContext()
    @globalSoundList = {}
    @lastLevelTheme = ""

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

    console.time "bufferSounds #{sound}"
    buffer = @audioContext.createBuffer(request.response, false)
    console.timeEnd "bufferSounds #{sound}"

    @globalSoundList[sound].buffer = buffer

    console.log sound+' loaded' if debug

    callback()


  ###
  @param [String]
  @param [Object]
  @param [Double]
  @param [Bool]
  Play sound of list with volume and loop
  ###
  playSound: (sound, volume, loops) =>
    if @globalSoundList[sound].isPlaying != true
      sourceNode = @audioContext.createBufferSource()
      sourceNode.buffer = @globalSoundList[sound].buffer
      sourceNode.loop = loops

      sourceNode.gain.value = volume
      sourceNode.connect(@audioContext.destination)

      @globalSoundList[sound].sourceNode = sourceNode

      sourceNode.start(0)
      @globalSoundList[sound].isPlaying = true
    else @fade sound, volume, @FADE_THEME_INTERVAL

  ###
  @param [String]
  @param [Object]
  Stop sound in list
  ###
  stop: (sound) =>
    if @globalSoundList[sound].isPlaying
      @globalSoundList[sound].sourceNode.stop(@audioContext.currentTime)
      @globalSoundList[sound].isPlaying = false
      console.log sound+'.mp3 stopped' if debug

  ###
  Stop all sounds in active level
  ###
  stopAll: (config) =>
    theme = mediator.getActiveLevel().themeSound
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
    try
      for name, sound of @globalSoundList
        if (soundsToStop.indexOf name) isnt -1
          @stop name
    catch e
      console.log e.toString() if debug


  ###
  Start all background sounds in backgroundSound list of active level with gain = 0, i.e. muted
  ###
  startBackgroundSounds: () =>
    for sound in mediator.getActiveLevel().backgroundSoundList
      @playSound sound, 0, true

  startThemeSound: () =>
    theme = mediator.getActiveLevel().themeSound
    intensity = mediator.getActiveLevel().themeIntensity
    if @lastLevelTheme == theme
      @fade theme, intensity, @FADE_THEME_INTERVAL
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
      @fade sound.type+'.mp3', sound.intensity/100, @FADE_BACKGROUND_INTERVAL
      @backgroundSoundsToPlay.push(sound.type+'.mp3')

    for sound in lvl.backgroundSoundList
      if @backgroundSoundsToPlay.indexOf(sound) == -1
        @fade sound, 0, @FADE_BACKGROUND_INTERVAL

  ###
  @param [String]
  @param [Object]
  @param [Double]
  Fade sound in list to gain
  ###
  fade: (sound, volume, interval) =>
    # exponentially approaching the target value <volume> at the given time with a rate <interval>
    @globalSoundList[sound].sourceNode.gain.setTargetAtTime(volume, @audioContext.currentTime, interval)


  startAll: =>
    @startThemeSound()
    @startBackgroundSounds()
    @updateBackgroundSounds(mediator.getActiveLevel().player.position)

