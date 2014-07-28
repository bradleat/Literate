App = Ember.Application.create
  LOG_TRANSITIONS: true
window.App = App

App.Router.map () ->
  @resource 'page', {path: '/*page_dir'}, () ->
    @resource 'code'
    @resource 'markdown'

require('./src/page')()
require('./src/code')()
require('./src/markdown')()
require('./src/state')()
require('./src/editor')()






#bookmaker.js npm
#front-mater npm/github
#marked.js npm
#mschat