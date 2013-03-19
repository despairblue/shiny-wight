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

window.require.register("test/models/Entity-test", Function('exports, require, module', "var Entity;\n\nEntity = require('models/Entity');\n\ndescribe('Entity', function() {\n  return beforeEach(function() {\n    return this.model = new Entity();\n  });\n});\n\n//@ sourceURL=test/models/Entity-test.coffee"));
window.require.register("test/models/InputManager-test", Function('exports, require, module', "var InputManager;\n\nInputManager = require('models/InputManager');\n\ndescribe('InputManager', function() {\n  return beforeEach(function() {\n    return this.model = new InputManager();\n  });\n});\n\n//@ sourceURL=test/models/InputManager-test.coffee"));
window.require.register("test/models/Player-test", Function('exports, require, module', "var Player;\n\nPlayer = require('models/Player');\n\ndescribe('Player', function() {\n  return beforeEach(function() {\n    return this.model = new Player();\n  });\n});\n\n//@ sourceURL=test/models/Player-test.coffee"));
window.require.register("test/models/TILEDMap-test", Function('exports, require, module', "var TILEDMap;\n\nTILEDMap = require('models/TILEDMap');\n\ndescribe('TILEDMap', function() {\n  return beforeEach(function() {\n    return this.model = new TILEDMap();\n  });\n});\n\n//@ sourceURL=test/models/TILEDMap-test.coffee"));
window.require.register("test/models/home-test", Function('exports, require, module', "var Home;\n\nHome = require('models/home');\n\ndescribe('Home', function() {\n  return beforeEach(function() {\n    return this.model = new Home();\n  });\n});\n\n//@ sourceURL=test/models/home-test.coffee"));
window.require.register("test/test-helpers", Function('exports, require, module', "var chai, sinonChai;\n\nchai = require('chai');\n\nsinonChai = require('sinon-chai');\n\nchai.use(sinonChai);\n\nmodule.exports = {\n  expect: chai.expect,\n  sinon: require('sinon')\n};\n\n//@ sourceURL=test/test-helpers.coffee"));
window.require.register("test/views/home-page-view-test", Function('exports, require, module', "var HomePageView;\n\nHomePageView = require('views/home-page-view');\n\ndescribe('HomePageView', function() {\n  beforeEach(function() {\n    return this.view = new HomePageView;\n  });\n  afterEach(function() {\n    return this.view.dispose();\n  });\n  return it('should auto-render', function() {\n    return expect(this.view.$el.find('img')).to.have.length(1);\n  });\n});\n\n//@ sourceURL=test/views/home-page-view-test.coffee"));
window.require('test/models/Entity-test');
window.require('test/models/InputManager-test');
window.require('test/models/Player-test');
window.require('test/models/TILEDMap-test');
window.require('test/models/home-test');
window.require('test/views/home-page-view-test');
