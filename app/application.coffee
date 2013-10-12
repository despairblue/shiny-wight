mediator = Chaplin.mediator
mapManager = require 'core/TILEDMap'
configurationManager = require 'core/configurationManager'
routes = require 'routes'

# The application object
module.exports = class Application extends Chaplin.Application
  # Set your application name here so the document title is set to
  # “Controller title – Site title” (see Layout#adjustTitle)
  title: 'shiny wight'

  initialize: ->
    @initGameSpecificStuff()
    super

  # Create additional mediator properties
  initMediator: ->
    # Add additional application-specific properties and methods
    # e.g. mediator.prop          = null
    mediator.homepageview         = null
    mediator.map                  = null
    mediator.soundManager         = null
    mediator.dialogManager        = null
    mediator.mapManager           = mapManager
    mediator.configurationManager = configurationManager
    # used while developing, so wie don't have to load sounds if we don't need to
    mediator.playWithSounds       = true
    mediator.renderDebug          = false
    mediator.disableDialogs       = false
    mediator.factory              = require 'entities/entities'
    mediator.levels               = {}
    mediator.activeLevel          = ''
    mediator.nextLevel            = ''
    mediator.std                  = null
    mediator.blockInput           = false
    mediator.gui                  = null
    mediator.getActiveLevel       = =>
      mediator.levels[mediator.activeLevel]

    # Seal the mediator
    super

  initGameSpecificStuff: ->
    # requestAnimationFrame polyfill
    (->
      lastTime = 0
      vendors = ["ms", "moz", "webkit", "o"]
      x = 0

      while x < vendors.length and not window.requestAnimationFrame
        window.requestAnimationFrame = window[vendors[x] + "RequestAnimationFrame"]
        window.cancelAnimationFrame = window[vendors[x] + "CancelAnimationFrame"] or window[vendors[x] + "CancelRequestAnimationFrame"]
        ++x
      unless window.requestAnimationFrame
        window.requestAnimationFrame = (callback, element) ->
          currTime = new Date().getTime()
          timeToCall = Math.max(0, 16 - (currTime - lastTime))
          id = window.setTimeout(->
            callback currTime + timeToCall
          , timeToCall)
          lastTime = currTime + timeToCall
          id
      unless window.cancelAnimationFrame
        window.cancelAnimationFrame = (id) ->
          clearTimeout id
    )()

    # check for debug mode
    window.debug = document.location.hash.match(/debug/) and console?

    # for box2d
    window.Logger = window.console

    # extend canvas 2d context to be able to draw with tiles instead of pixels as a unit
    Object.getPrototypeOf(document.createElement('canvas').getContext('2d')).drawImageTiled = (img, sx, sy, sw, sh, dx, dy, dw, dh, tileSizeX, tileSizeY) ->
      @drawImage img, sx * tileSizeX, sy * tileSizeY, sw * tileSizeX, sh * tileSizeY, dx * tileSizeX, dy * tileSizeY, dw * tileSizeX, dh * tileSizeY

    # only show debug messages when debug is enabled (append #debug to URL)
    console._debug = console.debug
    console.debug = ->
      console._debug.apply console, arguments if debug
