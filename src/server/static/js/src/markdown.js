// Generated by CoffeeScript 1.7.1
(function() {
  module.exports = function() {
    App.MarkdownRoute = Ember.Route.extend({
      model: function(_arg, transition) {
        var page;
        _arg;
        page = transition.params.page.page_dir;
        this.set('page', page);
        return $.ajax({
          url: "/tangle/" + page + "?mode=markdown",
          cache: false
        });
      },
      setupController: function(controller, model) {
        var res;
        res = {
          model: model,
          page: this.get('page')
        };
        App.state.toMarkdown(model, res.page);
        return controller.set('model', res);
      }
    });
    App.MarkdownController = Ember.ObjectController.extend({
      needs: "page"
    });
    return App.MarkdownView = Ember.View.extend({
      didInsertElement: function() {
        return App.state.toMarkdown(this.get('controller.content.model'), this.get('controller.content.page'));
      }
    });
  };

}).call(this);
