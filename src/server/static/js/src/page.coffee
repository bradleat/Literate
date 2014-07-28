module.exports = ->
  App.PageRoute = Ember.Route.extend
    actions: 
      reload: () ->
        @refresh()
    model: (params) ->
      @set 'page', params.page_dir
      return $.ajax url: "/tangle/#{params.page_dir}?mode=literate", cache: false
    setupController: (controller, model) ->
      unless model.page_dir?
        res =
          model: model
          page: @get 'page'

        App.state.toLiterate model, res.page

        controller.set 'model', res
      else
        App.state.toLiterate controller.content.model

  App.PageView = Ember.View.extend
    didInsertElement: () ->
      App.state.toLiterate @get('controller.content.model'), @get('controller.content.page')
      

  App.PageController = Ember.ObjectController.extend  
    actions:
      "toggle-editor": () ->
        App.state.toggleEditor @get 'page'

      "open-settings": ->
        App.state.openSettings()

      "save-refresh": () ->
        App.state.saveOrRefresh (@get 'page'), (mode, page) =>
          if mode is 'reload'
            @send "reload"
          else
            @transitionToRoute mode, {page_dir: page}
      "literate-start": () ->
        @transitionToRoute 'page', {page_dir: @get 'page'}
          
      "markdown-start": () ->
        @transitionToRoute 'markdown', {page_dir: @get 'page'}

      "code-start": () ->
        @transitionToRoute 'code', {page_dir: @get 'page'}