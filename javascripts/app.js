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

window.require.register("application", Function('exports, require, module', "var Application, Chaplin, Layout, mediator, routes,\n  __hasProp = {}.hasOwnProperty,\n  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };\n\nChaplin = require('chaplin');\n\nLayout = require('views/layout');\n\nmediator = require('mediator');\n\nroutes = require('routes');\n\nmodule.exports = Application = (function(_super) {\n\n  __extends(Application, _super);\n\n  function Application() {\n    return Application.__super__.constructor.apply(this, arguments);\n  }\n\n  Application.prototype.title = 'shiny wight';\n\n  Application.prototype.initialize = function() {\n    Application.__super__.initialize.apply(this, arguments);\n    this.initDispatcher({\n      controllerSuffix: '-controller'\n    });\n    this.initLayout();\n    this.initMediator();\n    this.initControllers();\n    this.initRouter(routes);\n    this.initGameSpecificStuff();\n    return typeof Object.freeze === \"function\" ? Object.freeze(this) : void 0;\n  };\n\n  Application.prototype.initLayout = function() {\n    return this.layout = new Layout({\n      title: this.title\n    });\n  };\n\n  Application.prototype.initControllers = function() {};\n\n  Application.prototype.initMediator = function() {\n    mediator.map = null;\n    mediator.factory = {};\n    mediator.entities = [];\n    return mediator.seal();\n  };\n\n  Application.prototype.initGameSpecificStuff = function() {\n    (function() {\n      var lastTime, vendors, x;\n      lastTime = 0;\n      vendors = [\"ms\", \"moz\", \"webkit\", \"o\"];\n      x = 0;\n      while (x < vendors.length && !window.requestAnimationFrame) {\n        window.requestAnimationFrame = window[vendors[x] + \"RequestAnimationFrame\"];\n        window.cancelAnimationFrame = window[vendors[x] + \"CancelAnimationFrame\"] || window[vendors[x] + \"CancelRequestAnimationFrame\"];\n        ++x;\n      }\n      if (!window.requestAnimationFrame) {\n        window.requestAnimationFrame = function(callback, element) {\n          var currTime, id, timeToCall;\n          currTime = new Date().getTime();\n          timeToCall = Math.max(0, 16 - (currTime - lastTime));\n          id = window.setTimeout(function() {\n            return callback(currTime + timeToCall);\n          }, timeToCall);\n          lastTime = currTime + timeToCall;\n          return id;\n        };\n      }\n      if (!window.cancelAnimationFrame) {\n        return window.cancelAnimationFrame = function(id) {\n          return clearTimeout(id);\n        };\n      }\n    })();\n    return needle.init(10000, false);\n  };\n\n  return Application;\n\n})(Chaplin.Application);\n\n//@ sourceURL=application.coffee"));
