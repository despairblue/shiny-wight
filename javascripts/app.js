(function(/*! Brunch !*/) {
  'use strict';

  var globals = typeof window !== 'undefined' ? window : global;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};

  var has = function(object, name) {
    return ({}).hasOwnProperty.call(object, name);
  };

  var expand = function(root, name) {
    var results = [], parts, part;
    if (/^\.\.?(\/|$)/.test(name)) {
      parts = [root, name].join('/').split('/');
    } else {
      parts = name.split('/');
    }
    for (var i = 0, length = parts.length; i < length; i++) {
      part = parts[i];
      if (part === '..') {
        results.pop();
      } else if (part !== '.' && part !== '') {
        results.push(part);
      }
    }
    return results.join('/');
  };

  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var localRequire = function(path) {
    return function(name) {
      var dir = dirname(path);
      var absolute = expand(dir, name);
      return globals.require(absolute);
    };
  };

  var initModule = function(name, definition) {
    var module = {id: name, exports: {}};
    definition(module.exports, localRequire(name), module);
    var exports = cache[name] = module.exports;
    return exports;
  };

  var require = function(name) {
    var path = expand(name, '.');

    if (has(cache, path)) return cache[path];
    if (has(modules, path)) return initModule(path, modules[path]);

    var dirIndex = expand(path, './index');
    if (has(cache, dirIndex)) return cache[dirIndex];
    if (has(modules, dirIndex)) return initModule(dirIndex, modules[dirIndex]);

    throw new Error('Cannot find module "' + name + '"');
  };

  var define = function(bundle, fn) {
    if (typeof bundle === 'object') {
      for (var key in bundle) {
        if (has(bundle, key)) {
          modules[key] = bundle[key];
        }
      }
    } else {
      modules[bundle] = fn;
    }
  };

  globals.require = require;
  globals.require.define = define;
  globals.require.register = define;
  globals.require.brunch = true;
})();

window.require.register("application", Function('exports, require, module', "var Application, Chaplin, Layout, mediator, routes,\n  __hasProp = {}.hasOwnProperty,\n  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };\n\nChaplin = require('chaplin');\n\nLayout = require('views/layout');\n\nmediator = require('mediator');\n\nroutes = require('routes');\n\nmodule.exports = Application = (function(_super) {\n\n  __extends(Application, _super);\n\n  function Application() {\n    return Application.__super__.constructor.apply(this, arguments);\n  }\n\n  Application.prototype.title = 'shiny wight';\n\n  Application.prototype.initialize = function() {\n    Application.__super__.initialize.apply(this, arguments);\n    this.initDispatcher({\n      controllerSuffix: '-controller'\n    });\n    this.initLayout();\n    this.initMediator();\n    this.initControllers();\n    this.initRouter(routes);\n    (function() {\n      var lastTime, vendors, x;\n      lastTime = 0;\n      vendors = [\"ms\", \"moz\", \"webkit\", \"o\"];\n      x = 0;\n      while (x < vendors.length && !window.requestAnimationFrame) {\n        window.requestAnimationFrame = window[vendors[x] + \"RequestAnimationFrame\"];\n        window.cancelAnimationFrame = window[vendors[x] + \"CancelAnimationFrame\"] || window[vendors[x] + \"CancelRequestAnimationFrame\"];\n        ++x;\n      }\n      if (!window.requestAnimationFrame) {\n        window.requestAnimationFrame = function(callback, element) {\n          var currTime, id, timeToCall;\n          currTime = new Date().getTime();\n          timeToCall = Math.max(0, 16 - (currTime - lastTime));\n          id = window.setTimeout(function() {\n            return callback(currTime + timeToCall);\n          }, timeToCall);\n          lastTime = currTime + timeToCall;\n          return id;\n        };\n      }\n      if (!window.cancelAnimationFrame) {\n        return window.cancelAnimationFrame = function(id) {\n          return clearTimeout(id);\n        };\n      }\n    })();\n    return typeof Object.freeze === \"function\" ? Object.freeze(this) : void 0;\n  };\n\n  Application.prototype.initLayout = function() {\n    return this.layout = new Layout({\n      title: this.title\n    });\n  };\n\n  Application.prototype.initControllers = function() {};\n\n  Application.prototype.initMediator = function() {\n    mediator.map = null;\n    mediator.factory = {};\n    return mediator.seal();\n  };\n\n  return Application;\n\n})(Chaplin.Application);\n\n//@ sourceURL=application.coffee"));
window.require.register("controllers/base/controller", Function('exports, require, module', "var Chaplin, Controller,\n  __hasProp = {}.hasOwnProperty,\n  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };\n\nChaplin = require('chaplin');\n\nmodule.exports = Controller = (function(_super) {\n\n  __extends(Controller, _super);\n\n  function Controller() {\n    return Controller.__super__.constructor.apply(this, arguments);\n  }\n\n  return Controller;\n\n})(Chaplin.Controller);\n\n//@ sourceURL=controllers/base/controller.coffee"));
window.require.register("controllers/home-controller", Function('exports, require, module', "var Controller, HomeController, HomePageView,\n  __hasProp = {}.hasOwnProperty,\n  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };\n\nController = require('controllers/base/controller');\n\nHomePageView = require('views/home-page-view');\n\nmodule.exports = HomeController = (function(_super) {\n\n  __extends(HomeController, _super);\n\n  function HomeController() {\n    return HomeController.__super__.constructor.apply(this, arguments);\n  }\n\n  HomeController.prototype.index = function() {\n    return this.view = new HomePageView({\n      gMap: this.gMap\n    });\n  };\n\n  return HomeController;\n\n})(Controller);\n\n//@ sourceURL=controllers/home-controller.coffee"));
window.require.register("initialize", Function('exports, require, module', "var Application;\n\nApplication = require('application');\n\n$(function() {\n  var app;\n  app = new Application();\n  return app.initialize();\n});\n\n//@ sourceURL=initialize.coffee"));
window.require.register("lib/support", Function('exports, require, module', "var Chaplin, support, utils;\n\nChaplin = require('chaplin');\n\nutils = require('lib/utils');\n\nsupport = utils.beget(Chaplin.support);\n\nmodule.exports = support;\n\n//@ sourceURL=lib/support.coffee"));
window.require.register("lib/utils", Function('exports, require, module', "var Chaplin, utils;\n\nChaplin = require('chaplin');\n\nutils = Chaplin.utils.beget(Chaplin.utils);\n\nmodule.exports = utils;\n\n//@ sourceURL=lib/utils.coffee"));
window.require.register("lib/view-helper", Function('exports, require, module', "var mediator,\n  __slice = [].slice;\n\nmediator = require('mediator');\n\nHandlebars.registerHelper('with', function(context, options) {\n  if (!context || Handlebars.Utils.isEmpty(context)) {\n    return options.inverse(this);\n  } else {\n    return options.fn(context);\n  }\n});\n\nHandlebars.registerHelper('without', function(context, options) {\n  var inverse;\n  inverse = options.inverse;\n  options.inverse = options.fn;\n  options.fn = inverse;\n  return Handlebars.helpers[\"with\"].call(this, context, options);\n});\n\nHandlebars.registerHelper('url', function() {\n  var params, routeName, url;\n  routeName = arguments[0], params = 2 <= arguments.length ? __slice.call(arguments, 1) : [];\n  url = null;\n  mediator.publish('!router:reverse', routeName, params, function(result) {\n    return url = result;\n  });\n  return \"/\" + url;\n});\n\n//@ sourceURL=lib/view-helper.coffee"));
window.require.register("mediator", Function('exports, require, module', "\nmodule.exports = require('chaplin').mediator;\n\n//@ sourceURL=mediator.coffee"));
window.require.register("models/DeadEntity", Function('exports, require, module', "var DeadEntity, VisibleEntity,\n  __hasProp = {}.hasOwnProperty,\n  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };\n\nVisibleEntity = require('models/VisibleEntity');\n\nmodule[\"extends\"] = DeadEntity = (function(_super) {\n\n  __extends(DeadEntity, _super);\n\n  function DeadEntity() {\n    return DeadEntity.__super__.constructor.apply(this, arguments);\n  }\n\n  return DeadEntity;\n\n})(VisibleEntity);\n\n//@ sourceURL=models/DeadEntity.coffee"));
window.require.register("models/Entity", Function('exports, require, module', "var Entity, Model, mediator,\n  _this = this,\n  __hasProp = {}.hasOwnProperty,\n  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };\n\nModel = require('models/base/model');\n\nmediator = require('mediator');\n\nmodule.exports = Entity = (function(_super) {\n\n  __extends(Entity, _super);\n\n  function Entity() {\n    var _this = this;\n    this.moveLeft = function() {\n      return Entity.prototype.moveLeft.apply(_this, arguments);\n    };\n    this.moveRight = function() {\n      return Entity.prototype.moveRight.apply(_this, arguments);\n    };\n    this.moveDown = function() {\n      return Entity.prototype.moveDown.apply(_this, arguments);\n    };\n    this.moveUp = function() {\n      return Entity.prototype.moveUp.apply(_this, arguments);\n    };\n    this.update = function() {\n      return Entity.prototype.update.apply(_this, arguments);\n    };\n    this.onAction = function(Object) {\n      return Entity.prototype.onAction.apply(_this, arguments);\n    };\n    return Entity.__super__.constructor.apply(this, arguments);\n  }\n\n  Entity.prototype.defaults = {\n    position: {\n      x: 0,\n      y: 0\n    }\n  };\n\n  Entity.prototype.animationStep = 0;\n\n  Entity.prototype.viewDirection = 0;\n\n  Entity.prototype.updateViewAndMove = function(vd) {\n    if (this.viewDirection !== vd) {\n      this.animationStep = 1;\n      return this.viewDirection = vd;\n    } else {\n      return this.animationStep++;\n    }\n  };\n\n  Entity.prototype.initialize = function() {\n    this.set({\n      'mediator': require('mediator')\n    });\n    return this.map = (this.get('mediator')).map;\n  };\n\n  Entity.prototype.onAction = function(Object) {};\n\n  Entity.prototype.update = function() {};\n\n  Entity.prototype.moveUp = function() {\n    var position;\n    position = this.get('position');\n    position.y--;\n    if (position.y < 0) {\n      position.y = 0;\n    }\n    this.set(position);\n    return this.updateViewAndMove(0);\n  };\n\n  Entity.prototype.moveDown = function() {\n    var numYTiles, position;\n    numYTiles = this.map.get('numYTiles');\n    position = this.get('position');\n    position.y++;\n    if (position.y > numYTiles) {\n      position.y = numYTiles;\n    }\n    this.set(position);\n    return this.updateViewAndMove(2);\n  };\n\n  Entity.prototype.moveRight = function() {\n    var numXTiles, position;\n    numXTiles = this.map.get('numXTiles');\n    position = this.get('position');\n    position.x++;\n    if (position.x > numXTiles) {\n      position.x = numXTiles;\n    }\n    this.set(position);\n    return this.updateViewAndMove(1);\n  };\n\n  Entity.prototype.moveLeft = function() {\n    var position;\n    position = this.get('position');\n    position.x--;\n    if (position.x < 0) {\n      position.x = 0;\n    }\n    this.set(position);\n    return this.updateViewAndMove(3);\n  };\n\n  return Entity;\n\n})(Model);\n\n//@ sourceURL=models/Entity.coffee"));
window.require.register("models/InputManager", Function('exports, require, module', "var InputManager, Model,\n  _this = this,\n  __hasProp = {}.hasOwnProperty,\n  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };\n\nModel = require('models/base/model');\n\nmodule.exports = InputManager = (function(_super) {\n\n  __extends(InputManager, _super);\n\n  function InputManager() {\n    var _this = this;\n    this.bind = function(key, action) {\n      return InputManager.prototype.bind.apply(_this, arguments);\n    };\n    this.onKeyUpEvent = function(event) {\n      return InputManager.prototype.onKeyUpEvent.apply(_this, arguments);\n    };\n    this.onKeyDownEvent = function(event) {\n      return InputManager.prototype.onKeyDownEvent.apply(_this, arguments);\n    };\n    this.initialize = function() {\n      return InputManager.prototype.initialize.apply(_this, arguments);\n    };\n    return InputManager.__super__.constructor.apply(this, arguments);\n  }\n\n  InputManager.prototype.defaults = {\n    bindings: {},\n    actions: {},\n    presses: {},\n    locks: {},\n    delayedKeyup: [],\n    keyCodes: {\n      'a': 65,\n      'w': 87,\n      'd': 68,\n      's': 83\n    }\n  };\n\n  InputManager.prototype.initialize = function() {\n    var keyCodes;\n    keyCodes = this.get('keyCodes');\n    this.bind(keyCodes['w'], 'move-up');\n    this.bind(keyCodes['a'], 'move-left');\n    this.bind(keyCodes['s'], 'move-down');\n    this.bind(keyCodes['d'], 'move-right');\n    window.addEventListener('keydown', this.onKeyDownEvent);\n    return window.addEventListener('keyup', this.onKeyUpEvent);\n  };\n\n  InputManager.prototype.onKeyDownEvent = function(event) {\n    var action, actions, bindings, code;\n    bindings = this.get('bindings');\n    actions = this.get('actions');\n    code = event['keyCode'];\n    action = bindings[code];\n    if (action) {\n      actions[action] = true;\n    }\n    return this.set({\n      'actions': actions\n    });\n  };\n\n  InputManager.prototype.onKeyUpEvent = function(event) {\n    var action, actions, bindings, code;\n    bindings = this.get('bindings');\n    actions = this.get('actions');\n    code = event['keyCode'];\n    action = bindings[code];\n    if (action) {\n      actions[action] = false;\n    }\n    return this.set({\n      'actions': actions\n    });\n  };\n\n  InputManager.prototype.bind = function(key, action) {\n    var bindings;\n    bindings = this.get('bindings');\n    return bindings[key] = action;\n  };\n\n  return InputManager;\n\n})(Model);\n\n//@ sourceURL=models/InputManager.coffee"));
window.require.register("models/InvisibleEntity", Function('exports, require, module', "var Entity, InvisibleEntity,\n  __hasProp = {}.hasOwnProperty,\n  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };\n\nEntity = require('models/Entity');\n\nmodule.exports = InvisibleEntity = (function(_super) {\n\n  __extends(InvisibleEntity, _super);\n\n  function InvisibleEntity() {\n    return InvisibleEntity.__super__.constructor.apply(this, arguments);\n  }\n\n  return InvisibleEntity;\n\n})(Entity);\n\n//@ sourceURL=models/InvisibleEntity.coffee"));
window.require.register("models/LivingEntity", Function('exports, require, module', "var LivingEntity, VisibleEntity,\n  __hasProp = {}.hasOwnProperty,\n  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },\n  _this = this;\n\nVisibleEntity = require('models/VisibleEntity');\n\nmodule.exports = LivingEntity = (function(_super) {\n\n  __extends(LivingEntity, _super);\n\n  function LivingEntity() {\n    return LivingEntity.__super__.constructor.apply(this, arguments);\n  }\n\n  return LivingEntity;\n\n})(VisibleEntity);\n\n({\n  defaults: {\n    level: 0,\n    hp: 0,\n    viewDirection: 0\n  },\n  die: function() {}\n});\n\n//@ sourceURL=models/LivingEntity.coffee"));
window.require.register("models/Npc", Function('exports, require, module', "var Npc, Person,\n  __hasProp = {}.hasOwnProperty,\n  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };\n\nPerson = require('models/Person');\n\nmodule.exports = Npc = (function(_super) {\n\n  __extends(Npc, _super);\n\n  function Npc() {\n    return Npc.__super__.constructor.apply(this, arguments);\n  }\n\n  mediator.factory['Npc'] = Npc;\n\n  return Npc;\n\n})(Person);\n\n//@ sourceURL=models/Npc.coffee"));
window.require.register("models/Person", Function('exports, require, module', "var LivingEntity, Person,\n  __hasProp = {}.hasOwnProperty,\n  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };\n\nLivingEntity = require('models/LivingEntity');\n\nmodule.exports = Person = (function(_super) {\n\n  __extends(Person, _super);\n\n  function Person() {\n    return Person.__super__.constructor.apply(this, arguments);\n  }\n\n  Person.prototype.defaults = {\n    name: \"\"\n  };\n\n  return Person;\n\n})(LivingEntity);\n\n//@ sourceURL=models/Person.coffee"));
window.require.register("models/Player", Function('exports, require, module', "var Person, Player, mediator,\n  __hasProp = {}.hasOwnProperty,\n  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };\n\nPerson = require('models/Person');\n\nmediator = require('mediator');\n\nmodule.exports = Player = (function(_super) {\n\n  __extends(Player, _super);\n\n  function Player() {\n    return Player.__super__.constructor.apply(this, arguments);\n  }\n\n  mediator.factory['Player'] = Player;\n\n  Player.prototype.animationState = [0, 1, 2, 1];\n\n  Player.prototype.render = function(ctx, cx, cy) {\n    var dh, dw, dx, dy, img, map, pos, sh, sw, sx, sy, tileSet;\n    map = (this.get('mediator')).map;\n    tileSet = this.get('tileSet');\n    pos = this.get('position');\n    img = this.get('atlas');\n    sx = this.animationState[this.animationStep % this.animationState.length] * tileSet.tilewidth;\n    sy = this.viewDirection * tileSet.tileheight;\n    sw = tileSet.tilewidth;\n    sh = tileSet.tileheight;\n    dx = (pos.x * 32) - cx;\n    dy = (pos.y * 32) - cy;\n    dw = 32;\n    dh = 32;\n    return ctx.drawImage(img, sx, sy, sw, sh, dx, dy, dw, dh);\n  };\n\n  return Player;\n\n})(Person);\n\n//@ sourceURL=models/Player.coffee"));
window.require.register("models/TILEDMap", Function('exports, require, module', "var Model, TILEDMap,\n  _this = this,\n  __hasProp = {}.hasOwnProperty,\n  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };\n\nModel = require('models/base/model');\n\nmodule.exports = TILEDMap = (function(_super) {\n\n  __extends(TILEDMap, _super);\n\n  function TILEDMap() {\n    var _this = this;\n    this.render = function() {\n      return TILEDMap.prototype.render.apply(_this, arguments);\n    };\n    this.getTilePacket = function(tileIndex) {\n      return TILEDMap.prototype.getTilePacket.apply(_this, arguments);\n    };\n    this.createTileSet = function(tileset) {\n      return TILEDMap.prototype.createTileSet.apply(_this, arguments);\n    };\n    this.parseMapJSON = function(mapJSON) {\n      return TILEDMap.prototype.parseMapJSON.apply(_this, arguments);\n    };\n    this.xhrGet = function(reqUri, callback) {\n      return TILEDMap.prototype.xhrGet.apply(_this, arguments);\n    };\n    return TILEDMap.__super__.constructor.apply(this, arguments);\n  }\n\n  TILEDMap.prototype.defaults = {\n    currMapData: null,\n    tileset: [],\n    numXTiles: 100,\n    numYTiles: 100,\n    tileSize: {\n      x: 64,\n      y: 64\n    },\n    pixelSize: {\n      x: 64,\n      y: 64\n    },\n    fullyLoaded: false,\n    canvas: null,\n    ctx: null\n  };\n\n  TILEDMap.prototype.initialize = function() {\n    var canvas, ctx;\n    TILEDMap.__super__.initialize.apply(this, arguments);\n    this.imgLoadCount = 0;\n    canvas = document.createElement('canvas');\n    ctx = canvas.getContext('2d');\n    this.set({\n      'canvas': canvas\n    });\n    this.set({\n      'ctx': ctx\n    });\n    return this.listenTo(this, 'change:fullyLoaded', this.render);\n  };\n\n  TILEDMap.prototype.xhrGet = function(reqUri, callback) {\n    var xhr;\n    xhr = new XMLHttpRequest();\n    xhr.open('GET', reqUri, true);\n    xhr.onload = callback;\n    return xhr.send();\n  };\n\n  TILEDMap.prototype.load = function(map) {\n    var _this = this;\n    return this.xhrGet(map, function(data) {\n      return _this.parseMapJSON(data.target.responseText);\n    });\n  };\n\n  TILEDMap.prototype.parseMapJSON = function(mapJSON) {\n    var currMapData, numXTiles, numYTiles, pixelSize, tileSize, tileset, tilesets;\n    currMapData = JSON.parse(mapJSON);\n    numXTiles = currMapData.width;\n    numYTiles = currMapData.height;\n    tileSize = {\n      x: currMapData.tileheight,\n      y: currMapData.tilewidth\n    };\n    pixelSize = {\n      x: numXTiles * tileSize.x,\n      y: numYTiles * tileSize.y\n    };\n    this.set({\n      'currMapData': currMapData\n    });\n    this.set({\n      'numXTiles': currMapData.width\n    });\n    this.set({\n      'numYTiles': currMapData.height\n    });\n    this.set({\n      'tileSize': tileSize\n    });\n    this.set({\n      'pixelSize': pixelSize\n    });\n    tilesets = (function() {\n      var _i, _len, _ref, _results;\n      _ref = currMapData.tilesets;\n      _results = [];\n      for (_i = 0, _len = _ref.length; _i < _len; _i++) {\n        tileset = _ref[_i];\n        _results.push(this.createTileSet(tileset));\n      }\n      return _results;\n    }).call(this);\n    return this.set({\n      'tilesets': tilesets\n    });\n  };\n\n  TILEDMap.prototype.createTileSet = function(tileset) {\n    var currMapData, img, tileSize, ts,\n      _this = this;\n    currMapData = this.get('currMapData');\n    tileSize = this.get('tileSize');\n    img = new Image();\n    img.onload = function() {\n      _this.imgLoadCount++;\n      if (_this.imgLoadCount === currMapData.tilesets.length) {\n        return _this.set({\n          'fullyLoaded': true\n        });\n      }\n    };\n    img.src = 'atlases/' + tileset.image.replace(/^.*[\\\\\\/]/, '');\n    return ts = {\n      firstgid: tileset.firstgid,\n      image: img,\n      imageheight: tileset.imageheight,\n      imagewidth: tileset.imagewidth,\n      name: tileset.name,\n      numXTiles: Math.floor(tileset.imagewidth / tileSize.x),\n      numYTiles: Math.floor(tileset.imageheight / tileSize.y)\n    };\n  };\n\n  TILEDMap.prototype.getTilePacket = function(tileIndex) {\n    var lTileX, lTileY, localIdx, pkt, tile, tileSize, tilesets, _i;\n    pkt = {\n      img: null,\n      px: 0,\n      py: 0\n    };\n    tile = null;\n    tilesets = this.get('tilesets');\n    tileSize = this.get('tileSize');\n    for (_i = tilesets.length - 1; _i >= 0; _i += -1) {\n      tile = tilesets[_i];\n      if (tile.firstgid <= tileIndex) {\n        break;\n      }\n    }\n    pkt.img = tile.image;\n    localIdx = tileIndex - tile.firstgid;\n    lTileX = Math.floor(localIdx % tile.numXTiles);\n    lTileY = Math.floor(localIdx / tile.numYTiles);\n    pkt.px = lTileX * tileSize.x;\n    pkt.py = lTileY * tileSize.y;\n    return pkt;\n  };\n\n  TILEDMap.prototype.render = function() {\n    var canvas, coords, ctx, currMapData, layer, numXTiles, numYTiles, tID, tPKT, tileIDX, tileSize, _i, _len, _ref, _results;\n    currMapData = this.get('currMapData');\n    tileSize = this.get('tileSize');\n    numXTiles = this.get('numXTiles');\n    numYTiles = this.get('numYTiles');\n    canvas = this.get('canvas');\n    ctx = this.get('ctx');\n    canvas.width = numXTiles * tileSize.x;\n    canvas.height = numYTiles * tileSize.y;\n    _ref = currMapData.layers;\n    _results = [];\n    for (_i = 0, _len = _ref.length; _i < _len; _i++) {\n      layer = _ref[_i];\n      if (layer.type !== 'tilelayer') {\n        continue;\n      }\n      if (layer.name === 'sound') {\n        continue;\n      }\n      _results.push((function() {\n        var _j, _len1, _ref1, _results1;\n        _ref1 = layer.data;\n        _results1 = [];\n        for (tileIDX = _j = 0, _len1 = _ref1.length; _j < _len1; tileIDX = ++_j) {\n          tID = _ref1[tileIDX];\n          if (tID === 0) {\n            continue;\n          }\n          tPKT = this.getTilePacket(tID);\n          coords = {\n            x: (tileIDX % numXTiles) * tileSize.x,\n            y: Math.floor(tileIDX / numYTiles) * tileSize.y\n          };\n          _results1.push(ctx.drawImage(tPKT.img, tPKT.px, tPKT.py, tileSize.x, tileSize.y, coords.x, coords.y, tileSize.x, tileSize.y));\n        }\n        return _results1;\n      }).call(this));\n    }\n    return _results;\n  };\n\n  return TILEDMap;\n\n})(Model);\n\n//@ sourceURL=models/TILEDMap.coffee"));
window.require.register("models/VisibleEntity", Function('exports, require, module', "var Entity, VisibleEntity,\n  _this = this,\n  __hasProp = {}.hasOwnProperty,\n  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };\n\nEntity = require('models/Entity');\n\nmodule.exports = VisibleEntity = (function(_super) {\n\n  __extends(VisibleEntity, _super);\n\n  function VisibleEntity() {\n    var _this = this;\n    this.getSprite = function() {\n      return VisibleEntity.prototype.getSprite.apply(_this, arguments);\n    };\n    return VisibleEntity.__super__.constructor.apply(this, arguments);\n  }\n\n  VisibleEntity.prototype.defaults = {\n    tileSet: {\n      image: \"\",\n      imageheight: 0,\n      imagewidth: 0,\n      name: \"\",\n      tileheight: 0,\n      tilewidth: 0\n    }\n  };\n\n  VisibleEntity.prototype.animationState = 0;\n\n  VisibleEntity.prototype.getSprite = function() {};\n\n  VisibleEntity.prototype.load = function() {\n    var img, tileSet;\n    tileSet = this.get('tileSet');\n    img = new Image();\n    img.src = tileSet.image;\n    return this.set({\n      'atlas': img\n    });\n  };\n\n  VisibleEntity.prototype.render = function(ctx, cx, cy) {};\n\n  return VisibleEntity;\n\n})(Entity);\n\n//@ sourceURL=models/VisibleEntity.coffee"));
window.require.register("models/base/collection", Function('exports, require, module', "var Chaplin, Collection, Model,\n  __hasProp = {}.hasOwnProperty,\n  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };\n\nChaplin = require('chaplin');\n\nModel = require('models/base/model');\n\nmodule.exports = Collection = (function(_super) {\n\n  __extends(Collection, _super);\n\n  function Collection() {\n    return Collection.__super__.constructor.apply(this, arguments);\n  }\n\n  Collection.prototype.model = Model;\n\n  return Collection;\n\n})(Chaplin.Collection);\n\n//@ sourceURL=models/base/collection.coffee"));
window.require.register("models/base/model", Function('exports, require, module', "var Chaplin, Model,\n  __hasProp = {}.hasOwnProperty,\n  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };\n\nChaplin = require('chaplin');\n\nmodule.exports = Model = (function(_super) {\n\n  __extends(Model, _super);\n\n  function Model() {\n    return Model.__super__.constructor.apply(this, arguments);\n  }\n\n  return Model;\n\n})(Chaplin.Model);\n\n//@ sourceURL=models/base/model.coffee"));
window.require.register("models/home", Function('exports, require, module', "var Home, Model,\n  __hasProp = {}.hasOwnProperty,\n  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };\n\nModel = require('models/base/model');\n\nmodule.exports = Home = (function(_super) {\n\n  __extends(Home, _super);\n\n  function Home() {\n    return Home.__super__.constructor.apply(this, arguments);\n  }\n\n  return Home;\n\n})(Model);\n\n//@ sourceURL=models/home.coffee"));
window.require.register("models/moveState", Function('exports, require, module', "var moveState;\n\ni++;\n\nmoveState = [i % moveState.length];\n\n//@ sourceURL=models/moveState.coffee"));
window.require.register("routes", Function('exports, require, module', "\nmodule.exports = function(match) {\n  match('', 'home#index');\n  return match('u/6045251/shiny-wight/index.html', 'home#index');\n};\n\n//@ sourceURL=routes.coffee"));
window.require.register("views/base/collection-view", Function('exports, require, module', "var Chaplin, CollectionView, View,\n  __hasProp = {}.hasOwnProperty,\n  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };\n\nChaplin = require('chaplin');\n\nView = require('views/base/view');\n\nmodule.exports = CollectionView = (function(_super) {\n\n  __extends(CollectionView, _super);\n\n  function CollectionView() {\n    return CollectionView.__super__.constructor.apply(this, arguments);\n  }\n\n  CollectionView.prototype.getTemplateFunction = View.prototype.getTemplateFunction;\n\n  return CollectionView;\n\n})(Chaplin.CollectionView);\n\n//@ sourceURL=views/base/collection-view.coffee"));
window.require.register("views/base/view", Function('exports, require, module', "var Chaplin, View,\n  __hasProp = {}.hasOwnProperty,\n  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };\n\nChaplin = require('chaplin');\n\nrequire('lib/view-helper');\n\nmodule.exports = View = (function(_super) {\n\n  __extends(View, _super);\n\n  function View() {\n    return View.__super__.constructor.apply(this, arguments);\n  }\n\n  View.prototype.getTemplateFunction = function() {\n    return this.template;\n  };\n\n  return View;\n\n})(Chaplin.View);\n\n//@ sourceURL=views/base/view.coffee"));
window.require.register("views/home-page-view", Function('exports, require, module', "var HomePageView, InputManager, Player, TILEDMap, View, mediator,\n  _this = this,\n  __hasProp = {}.hasOwnProperty,\n  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };\n\nView = require('views/base/view');\n\nTILEDMap = require('models/TILEDMap');\n\nPlayer = require('models/Player');\n\nInputManager = require('models/InputManager');\n\nmediator = require('mediator');\n\nmodule.exports = HomePageView = (function(_super) {\n\n  __extends(HomePageView, _super);\n\n  function HomePageView() {\n    var _this = this;\n    this.draw = function() {\n      return HomePageView.prototype.draw.apply(_this, arguments);\n    };\n    this.handleInput = function() {\n      return HomePageView.prototype.handleInput.apply(_this, arguments);\n    };\n    this.doTheWork = function() {\n      return HomePageView.prototype.doTheWork.apply(_this, arguments);\n    };\n    this.setup = function() {\n      return HomePageView.prototype.setup.apply(_this, arguments);\n    };\n    return HomePageView.__super__.constructor.apply(this, arguments);\n  }\n\n  HomePageView.prototype.autoRender = true;\n\n  HomePageView.prototype.className = 'home-page';\n\n  HomePageView.prototype.container = '#page-container';\n\n  HomePageView.prototype.initialize = function(options) {\n    var _this = this;\n    HomePageView.__super__.initialize.apply(this, arguments);\n    this.gMap = new TILEDMap();\n    this.skipFrame = true;\n    this.listenTo(this.gMap, 'change:fullyLoaded', function(gMap, fullyLoaded) {\n      if (fullyLoaded) {\n        return _this.setup();\n      }\n    });\n    this.gMap.load('map/level1.json');\n    return mediator.map = this.gMap;\n  };\n\n  HomePageView.prototype.setup = function() {\n    var position, tileSet;\n    this.inputManager = new InputManager();\n    this.player = new Player();\n    position = {\n      x: 2,\n      y: 7\n    };\n    this.player.set({\n      'position': position\n    });\n    tileSet = {\n      image: \"atlases/warrior_m.png\",\n      imageheight: 96,\n      imagewidth: 144,\n      name: \"player\",\n      tileheight: 32,\n      tilewidth: 32\n    };\n    this.player.set({\n      'tileSet': tileSet\n    });\n    this.player.load();\n    return window.requestAnimationFrame(this.doTheWork);\n  };\n\n  HomePageView.prototype.render = function() {\n    this.canvas = document.createElement('canvas');\n    this.ctx = this.canvas.getContext('2d');\n    return this.el.appendChild(this.canvas);\n  };\n\n  HomePageView.prototype.doTheWork = function() {\n    var _this = this;\n    return setTimeout(function() {\n      window.requestAnimationFrame(_this.doTheWork);\n      _this.handleInput();\n      return _this.draw();\n    }, 1000 / 25);\n  };\n\n  HomePageView.prototype.handleInput = function() {\n    var actions, position;\n    actions = this.inputManager.get('actions');\n    position = this.player.get('position');\n    if (actions['move-up']) {\n      this.player.moveUp();\n    }\n    if (actions['move-down']) {\n      this.player.moveDown();\n    }\n    if (actions['move-left']) {\n      this.player.moveLeft();\n    }\n    if (actions['move-right']) {\n      return this.player.moveRight();\n    }\n  };\n\n  HomePageView.prototype.draw = function() {\n    var dh, dw, dx, dy, numXTiles, numYTiles, pos, sh, sw, sx, sy, tileSize;\n    this.canvas.width = window.innerWidth;\n    this.canvas.height = window.innerHeight;\n    tileSize = this.gMap.get('tileSize');\n    numXTiles = this.gMap.get('numXTiles');\n    numYTiles = this.gMap.get('numYTiles');\n    pos = this.player.get('position');\n    sx = (pos.x - 5) * tileSize.x;\n    sy = (pos.y - 5) * tileSize.y;\n    sw = dw = 11 * tileSize.x;\n    sh = dh = 11 * tileSize.y;\n    dx = 0;\n    dy = 0;\n    if (sx < 0) {\n      sx = 0;\n    }\n    if (sy < 0) {\n      sy = 0;\n    }\n    if (sx > numXTiles * tileSize.x) {\n      sx = numXTiles * tileSize.x;\n    }\n    if (sy > numYTiles * tileSize.y) {\n      sy = numYTiles * tileSize.y;\n    }\n    this.ctx.drawImage(this.gMap.get('canvas'), sx, sy, sw, sh, dx, dy, dw, dh);\n    return this.player.render(this.ctx, sx, sy);\n  };\n\n  return HomePageView;\n\n})(View);\n\n//@ sourceURL=views/home-page-view.coffee"));
window.require.register("views/layout", Function('exports, require, module', "var Chaplin, Layout,\n  __hasProp = {}.hasOwnProperty,\n  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };\n\nChaplin = require('chaplin');\n\nmodule.exports = Layout = (function(_super) {\n\n  __extends(Layout, _super);\n\n  function Layout() {\n    return Layout.__super__.constructor.apply(this, arguments);\n  }\n\n  return Layout;\n\n})(Chaplin.Layout);\n\n//@ sourceURL=views/layout.coffee"));
