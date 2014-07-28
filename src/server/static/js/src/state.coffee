module.exports = ->
  App.state =
    state: null
    editor: null
    editting: false
    store:
      code: {}
      markdown: {}
      literate: {}

    openSettings: ->
      if @editor?
        @editor.showSettingsMenu()
    
    _startEditor: ->
      @editor = ace.edit 'editor'
      window.editor = @editor #dev-only
      $('#editor').hide()
      $('#editor').css 'overflow-y', 'auto'
      ace.require("ace/ext/settings_menu").init editor

    saveOrRefresh: (page, cb) ->
      if @editting
        $.ajax
          type: "PUT"
          url: "/tangle/#{@editting.page}?mode=#{@editting.mode}"
          data: "edit": @editor.getValue()
        .done (data) =>
          cb @editting.mode, @editting.page
      else if @state is 'literate'
        $.ajax
          type: "PUT"
          url: "/tangle/#{page}?mode=render"
        .done (data) =>
          cb 'reload'

    openEditor: (page) ->
      @editting = 
        page: page
        mode: @state
      
      $('#save-refresh-icon').removeClass "glyphicon-leaf"
      $('#save-refresh-icon').addClass "glyphicon-floppy-disk"
            
      unless @editor?
        @_startEditor()  

      $('#editor').css 'min-height', $(window).height() * 0.85
      if @state is 'code'
        $('#editor').fadeIn "slow", () ->
          $('#code-render-target').slideUp "slow"
        @editor.setValue @store[@state][page].code
        @editor.session.setMode "ace/mode/#{@store[@state][page].type}"
      else if @state is 'markdown'
        $('#editor').fadeIn "slow", () ->
          $('#markdown-render-target').slideUp "slow"
        @editor.setValue @store[@state][page]
        @editor.session.setMode "ace/mode/markdown"


      $('#edit-button').fadeOut "fast", ->
        $('#edit-icon').removeClass "glyphicon-pencil"
        $('#edit-icon').addClass "glyphicon-eject"
        $('#edit-button').fadeIn "slow"

      @editor.resize()

    closeEditor: () ->

      $('#save-refresh-icon').removeClass "glyphicon-floppy-disk"
      $('#save-refresh-icon').addClass "glyphicon-leaf"
      
      @editting = false
      $('#editor').fadeOut "fast", () ->
        $('#markdown-render-target').slideDown "slow"
        $('#code-render-target').slideDown "slow"

      $('#edit-button').fadeOut "fast", ->
        $('#edit-icon').removeClass "glyphicon-eject"
        $('#edit-icon').addClass "glyphicon-pencil"
        $('#edit-button').fadeIn "slow"

    toggleEditor: (page) ->
      if @editting
        alert "warning" if @editting.page is not page
        @closeEditor page
      else
        @openEditor page

      
    toMarkdown: (model, page) ->
      document.title = "#{page} - markdown" if page?
      $('#markdown-tab').addClass 'active'
      $('#literate-tab').removeClass 'active'
      $('#code-tab').removeClass 'active'
      $('#page-render-target').slideUp()
      $('#edit-button').fadeIn()    
      $('#markdown-render-target').html model.html
      $('#markdown-render-target').children().find("code").each (i, block) ->
        if $(block).attr('class')?
          hljs.highlightBlock block

      @state = "markdown"
      @store[@state][page] = model.md
    toCode: (model, page) ->
      document.title = "#{page} - code" if page?
      $('#code-tab').addClass 'active'
      $('#literate-tab').removeClass 'active'
      $('#markdown-tab').removeClass 'active'
      $('#page-render-target').slideUp()      
      $('#edit-button').fadeIn()
      $('#code-render-target').html "<pre><code>#{model.code}</code></pre>"
      $('#code-render-target').find("code").each (i, block) -> hljs.highlightBlock block

      @state = "code"
      @store[@state][page] = model
    toLiterate: (model, page) ->
      document.title = "#{page} - literate" if page?
      $('#literate-tab').addClass 'active'
      $('#markdown-tab').removeClass 'active'
      $('#code-tab').removeClass 'active'
      $('#page-render-target').slideDown()
      
      
      $('#edit-button').fadeOut()
      $('#page-render-target').html model.html
      $('#page-render-target').children().find("code").each (i, block) ->
        if $(block).attr('class')?
          hljs.highlightBlock block

      @state = "literate"
      @store[@state][page] = model.md