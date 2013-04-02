Chaplin = require 'chaplin'
Layout = require 'views/layout'
mediator = require 'mediator'
routes = require 'routes'

# The application object
module.exports = class Application extends Chaplin.Application
  # Set your application name here so the document title is set to
  # “Controller title – Site title” (see Layout#adjustTitle)
  title: 'shiny wight'

  initialize: ->
    super

    # Initialize core components
    @initDispatcher controllerSuffix: '-controller'
    @initLayout()
    @initMediator()

    # Application-specific scaffold
    @initControllers()

    @initGameSpecificStuff()

    # Register all routes and start routing
    @initRouter routes
    # You might pass Router/History options as the second parameter.
    # Chaplin enables pushState per default and Backbone uses / as
    # the root per default. You might change that in the options
    # if necessary:
    # @initRouter routes, pushState: false, root: '/subdir/'

    # Freeze the application instance to prevent further changes
    Object.freeze? this

  # Override standard layout initializer
  # ------------------------------------
  initLayout: ->
    # Use an application-specific Layout class. Currently this adds
    # no features to the standard Chaplin Layout, it’s an empty placeholder.
    @layout = new Layout {@title}

  # Instantiate common controllers
  # ------------------------------
  initControllers: ->
    # These controllers are active during the whole application runtime.
    # You don’t need to instantiate all controllers here, only special
    # controllers which do not to respond to routes. They may govern models
    # and views which are needed the whole time, for example header, footer
    # or navigation views.
    # e.g. new NavigationController()

  # Create additional mediator properties
  # -------------------------------------
  initMediator: ->
    # Add additional application-specific properties and methods
    # e.g. mediator.prop = null
    mediator.map            = null
    mediator.physicsManager = null
    mediator.soundManager   = null
    mediator.mapManager     = null
    # used while developing, so wie don't have to load sounds if we don't need to
    mediator.playWithSounds = false
    mediator.factory        = {}
    mediator.entities       = []
    mediator.levels         = {}
    mediator.activeLevel    = ""
    mediator.std            = null
    mediator.getActiveLevel = =>
      mediator.levels[mediator.activeLevel]

    # Seal the mediator
    mediator.seal()

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

    # extend canvas 2d context to be able to draw with tiles instead of pixels as a unit
    Object.getPrototypeOf(document.createElement('canvas').getContext('2d')).drawImageTiled = (img, sx, sy, sw, sh, dx, dy, dw, dh, tileSizeX, tileSizeY) ->
      @drawImage img, sx * tileSizeX, sy * tileSizeY, sw * tileSizeX, sh * tileSizeY, dx * tileSizeX, dy * tileSizeY, dw * tileSizeX, dh * tileSizeY

