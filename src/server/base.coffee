express = require 'express'
preview = require './service/preview'
editor  = require './service/editor'
fs      = require 'fs'
bodyParser = require 'body-parser'
module.exports = class server
  constructor: (dir, @debug = false, @verbose = true) ->
    @app = express()
    @app.use '/static', express.static __dirname + '/static'
    @app.get '/', (req, res) ->
      res.sendfile "#{__dirname}/static/index.html"
    book = "#{dir}/book.json"
    @app.listen 3000
    book = fs.readFile book, {encoding: 'utf8'}, (err, data) =>
      if err?
        throw err
      else
        @book = JSON.parse data
        @book.dir = dir

    #@book = require  "#{process.execPath}#{@book}"

  #should always start preview mode...
  startService: (service = 'preview') -> #editor or #preview
    unless @app.enabled service and service in ['editor', 'preview']
      @app.enable service
      console.log "Service \"#{service}\" started!"
      router = express.Router()
      if service is 'editor'
        @app.use "/tangle/", bodyParser.urlencoded({extended: false})
        @app.use "/tangle/", bodyParser.text()
      @app.use "/tangle/", router
      unless @debug
        router.use (req, res, next) ->
          if req.xhr
            next()
          else
            next new Error 'not implemented'

      if @verbose
        router.use (req, res, next) ->
          #some logic for verbose output
          #ie. saving, fetching, rerendering, etc
          next()

      router.route '/'
        .get (req, res, next) ->
          #inject code needed for the service
          next new Error 'not implemented'
        .put (req, res, next) ->
          res.send 404
        .post (req, res, next) ->
          res.send 404
        .delete (req, res, next) ->
          res.send 404
          

      router.route /\/(.+)/ #editor or preview
        .get (req, res, next) =>
          preview @book, req.params[0], req.query, (err, data) ->
            if err?
              next err
            else
              res.send data
        .put (req, res, next) =>
          if @app.enabled 'editor'
            editor @book, req.params[0], req.query, req.body , (err, data) ->
              if err?
                next err
              else
                res.send data
          else
            res.send 'not implemented'
        .post (req, res, next) ->
          res.send 'not implemented'
        .delete (req, res, next) ->
          res.send 'not implemented'

