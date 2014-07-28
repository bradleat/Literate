##Includes#
fs = require 'fs'
BlockParser = require('./CodeBlock')
RSVP = require('rsvp')
##constructor#
module.exports = class CodeParser
  constructor: (@debug = true) ->
    #Properties to be defined after an instancetgt
    
    @block = new BlockParser
    @_lexical()
    @tree = {}

    if @debug?
      console.log "#{@lang} CodeParser: Started"


  ##lexical#
  _lexical: () ->
    #myBlockParser extends BlockParser should override _lexical
    @blockbegin =  /#(?!{)#(.+)#/
    @blockend = /#(?!{)#end#/
    @lang = "coffee"

  ##parse#
  parse: (filename) ->
    parseTree = new RSVP.Promise (resolve, reject) =>
      #Init some variables we need later
      state = {}
      state.filename = filename
      state.tree = {}
      state.ExplicitEnded = false
      state.blockdepth = 0
      state.blockTrace = [] #We are in no block
      state.line = 0 #Initialize the line counter
      
    
      fs.readFile filename, {encoding: 'utf8'}, (err, data) =>
        if err
          err.text = "Error: Could not read #{filename} in Code Parsing step"
          reject err
        else
          file = data.toString().split '\n'
          [..., last] = file
          for line in file
            state.line++ #Increment line count for eachLine
            #Explictly ended block
            if (line.match @blockend)?
              @block.onExplicitEndToken state
              console.warn "Explictly ended blocks are not currently supported  (#{filename})!!"
            #Entering a Block:
            else if (line.match @blockbegin)? #if our line begin token is present
              blockname = @blockbegin.exec line #Store the match
              blockname = blockname[1] #We don't want the array
              
              #From BlockParser.coffee
              @block.onBeginToken blockname, state
            else if line is last
              state.tree.lang = @lang
              state.tree[state.blockTrace.pop()].end = state.line
              @tree[filename] = state.tree
          resolve @tree #resolve the promise