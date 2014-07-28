fs = require 'fs'

{print} = require 'sys'
{exec} = require 'child_process'

build = (callback) ->
  coffee = exec 'coffee -c src/server/static/js'
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  coffee.on 'exit', (code) ->
    browserify = exec 'browserify src/server/static/js/app.js -o src/server/static/js/app.min.js --bare -d'
    browserify.stderr.on 'data', (data) ->
    	process.stderr.write data.toString()
    browserify.stdout.on 'data', (data) ->
      print data.toString()


    callback?() if code is 0

task 'sbuild', 'Build server assets/', ->
  build()

task 'build', 'Build server assets/', ->
  build()