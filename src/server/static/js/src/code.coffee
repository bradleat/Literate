module.exports = ->
  App.CodeRoute = Ember.Route.extend
    model: ({}, transition) ->
      page = transition.params.page.page_dir
      @set 'page', page
      return $.ajax url: "/tangle/#{page}?mode=code", cache: false
    setupController: (controller, model) ->
      res = 
        model: model
        page: @get 'page'



      App.state.toCode model, res.page
      
      controller.set 'model', res

  App.CodeController = Ember.ObjectController.extend
    needs: "page"

  App.CodeView = Ember.View.extend
    didInsertElement: () ->
      App.state.toCode @get('controller.content.model'), @get('controller.content.page')