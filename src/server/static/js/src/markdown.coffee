module.exports = ->  
  App.MarkdownRoute = Ember.Route.extend
    model: ({}, transition) ->
      page = transition.params.page.page_dir
      @set 'page', page
      return $.ajax url: "/tangle/#{page}?mode=markdown", cache: false
    setupController: (controller, model) ->
      res = 
        model: model
        page: @get 'page'

      App.state.toMarkdown model, res.page

      controller.set 'model', res

  App.MarkdownController = Ember.ObjectController.extend
    needs: "page"

  App.MarkdownView = Ember.View.extend
    didInsertElement: () ->
      App.state.toMarkdown @get('controller.content.model'), @get('controller.content.page')