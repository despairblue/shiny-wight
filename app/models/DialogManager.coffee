mediator = require 'mediator'

module.exports = class DialogManager
  constructor: ->
    @source = document.getElementById 'dialog-template'
    @template = Handlebars.compile(@source.innerText)
    @canvas = document.getElementById 'game-canvas'
    mediator.dialogManager = @

  showDialog: (data, callback) =>
    result = $ @template(data)
    that = this

    result.children('.dialog-option').click (event) ->
      that.hideDialog()
      id = parseInt( $(this).prop('id') )
      callback(id + 1) if callback

    $('#dialog').append(result).
    css('left', 0).
    css('top', @canvas.height + 2).
    css('width', @canvas.width).
    fadeIn()


  hideDialog: () =>
    $('#dialog').empty()
