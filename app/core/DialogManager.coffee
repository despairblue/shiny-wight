mediator = require 'mediator'

module.exports = class DialogManager
  constructor: ->
    @source = document.getElementById 'dialog-template'
    @template = Handlebars.compile(@source.innerText)
    @canvas = document.getElementById 'game-canvas'
    @$dialog = $('#dialog')
    @currentSelection = 1
    mediator.dialogManager = @
    @didIBlock = false

    @selectOption = _.debounce @_selectOption, 50, true
    @chooseCurrentSelection = _.debounce @_chooseCurrentSelection, 50, true


  moveSelectionDown: =>
    @selectOption(@currentSelection + 1)


  moveSelectionUp: =>
    @selectOption(@currentSelection - 1)


  _selectOption: (optNum) =>
    # careful, first one is the actual text and not an option
    options = @$dialog.children().children()

    # TODO: rewrite, mod what huh?
    optNum  = options.length - 1 if optNum < 1
    optNum  = ( (optNum - 1) % (options.length - 1) ) + 1 # modulo magic, should be replaced to make it readable

    options.removeClass 'dialog-option-hovered'
    options.eq(optNum).addClass 'dialog-option-hovered'

    @currentSelection = optNum


  _chooseCurrentSelection: =>
    @$dialog.children().children().eq(@currentSelection).click()


  isDialog: =>
    @$dialog.children().length isnt 0


  showDialog: (data) =>
    deferred = Q.defer()

    if mediator.disableDialogs
      deferred.resolve()
      return

    if @isDialog()
      console.error "I'm already showing a dialog, so you must be doing something wrong!"
      deferred.reject()
      return

    @blockInput()

    result = $ @template(data)

    console.debug 'Show dialog: %O', data

    result.children('.dialog-option').click (event) =>
      @hideDialog()
      id = parseInt( $(this).prop('id') ) + 1
      id = -1 if id == NaN
      deferred.resolve id

    $('#dialog').append(result).
    css('left', 0).
    css('top', @canvas.height + 2).
    css('width', @canvas.width).
    fadeIn()

    @selectOption 1

    return deferred.promise


  hideDialog: () =>
    $('#dialog').empty()
    @unblockInput()


  blockInput: =>
    if mediator.blockInput
      # already blocked, so not my cup of tea to unblock it
      @didIBlock = false
    else
      # oh I need to remember to unblock it my self
      @didIBlock = true

    mediator.blockInput = true


  unblockInput: =>
    if @didIBlock
      mediator.blockInput = false
      @didIBlock = false
