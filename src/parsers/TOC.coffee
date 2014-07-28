##Includes#
RSVP = require 'rsvp'
fs   = require 'fs'
{meta} = require '../helpers'


##constructor#
module.exports = class TOC
  constructor: (@debug = true) ->

    if @debug?
      console.log "TOC TreeBuilder: Started"
    
      @table = []
      @walkPromises = {}
  ##parse#
  parse: (filename) ->
    #capture for TOC entry
    capture = /\[(.+)\]\((.+)\)/
    
    locations = []

    
    promise = new RSVP.Promise (resolve, reject) ->
      #read the file in
      fs.readFile filename, {encoding: 'utf8'}, (err, data) ->
        if err?
          err.text = "Could not open #{err.path} to parse the TOC of #{filename}!"
          reject err
        else
          TOC = (meta data)?.TOC
          if TOC?
            for entry in TOC
              locations.push (capture.exec entry)[2]
          
          resolve locations

  ##walk#
  walkAndParse: (file) ->
    @recursiveParseStart(file).then =>
      return RSVP.hash @walkPromises
    .then =>
      return @table
    
  recursiveParseStart: (file) ->
    @walkPromises[file] = new RSVP.Promise (resolve, reject) =>
      @parse(file).then (entries) =>
        for location in entries
          unless location in @table
            @table.push location
            @recursiveParseStart location
        resolve @table
      .catch (err) ->
        console.warn "Warn: #{err.text}"
        resolve @table

    