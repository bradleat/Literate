module.exports = ->
  App.EditorController = Ember.Component.extend
    actions:
      "say": () ->
        console.log "say you don't say"