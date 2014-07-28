##File Definitions#
read = require('line-reader')
RSVP = require('rsvp')
{typeOf} = require('../helpers')
{flatten} = require('lodash')
##Block Parser Class#
module.exports = class Seamstress
  constructor: (@debug = true) ->
    #Properties to be defined after an instance
    
    @_lexical()
    @extractionPromises = {}
    if @debug?
      console.log "#{@lang} Seamstress: Started"

  ##Parsing Grammar#
  _lexical: () ->
    @blockNameStartJunk = "#["
    @blockNameEndJunk = "]:("
    @fileNameEndJunk = ")"
    @inlineStatement =  /#\[(.+)\]:\((.+)\)/
    @lang = "Markdown"

    

  ##Parsing#
  sewFile: (filename, lookUpTree, patchTree = null) ->
    sew = RSVP['defer']()
    @_scanFile(filename, lookUpTree, patchTree).then (scan) =>
      #waits for all promises to be completed
      RSVP.hash(@extractionPromises).then (codeBlocks) ->
        for line, i in scan
          if (typeOf line) is 'array'
            lang = lookUpTree[line[0]].lang
            title = "# #{line[2]}"
            blockSrc = " (from block #{line[1]} found in #{line[0]})"
            codeBlocks[line].unshift title + blockSrc
            codeBlocks[line].unshift "```#{lang}"
            codeBlocks[line].push "```"
            scan[i] = codeBlocks[line]
        scan = flatten scan
        for line, i in scan
          scan[i] = line + "\n"
        sew.resolve scan
    return sew.promise
        
  prepareFile: (filename) ->
    scan = RSVP['defer']()
    scannedFile = {}
    read.eachLine filename, (line, last) =>
      if (line.match @inlineStatement)#we have an inline block
        sewFrom = (@_inlineStatementResolve line)[0]
        scannedFile[sewFrom] = true
      if last
        scan.resolve (src for src of scannedFile)
        return false
    return scan.promise


  _scanFile: (filename, lookUpTree, patchTree = null) ->
    scan = RSVP['defer']()
    scannedFile = []
    read.eachLine filename, (line, last) =>
      if (line.match @inlineStatement)#we have an inline block
        sewFrom = @_inlineStatementResolve line
        if patchTree?
          sewFrom[0] = patchTree[sewFrom[0]]
        scannedFile.push sewFrom
        unless lookUpTree[sewFrom[0]]?[sewFrom[1]]?
          #TODO: Fail more gracefully in the future
          throw ("Invalid reference to #{sewFrom[0]}, Block #{sewFrom[1]} from #{filename}")
        @_extractBlock sewFrom, lookUpTree[sewFrom[0]][sewFrom[1]]
        #TODO: Move the lookup tree to the constuctor
      else unless last
        scannedFile.push line #add each line to our scannedFile
      else
        scannedFile.push line
        scan.resolve scannedFile
        return false
    return scan.promise

  _inlineStatementResolve: (line) ->
    line = line.match @inlineStatement
    line = line[0] #gets rid of the array
    line = line.replace @blockNameStartJunk, ''
    stripFrom = line.indexOf @blockNameEndJunk
    sewFrom = line.substring stripFrom, line.length - 1
    sewFrom = sewFrom.replace @blockNameEndJunk, ''
    sewFrom = sewFrom.split ':'
    sewFrom[2] = line.substring 0, stripFrom
    #sewFrom[0] is the filename to sew from
    #sewFrom[1] is the blockname to sew from
    #sewFrom[2] is the literate name for the block
    return sewFrom

  _extractBlock: (sewSrc, blockLoc) ->
    extraction = RSVP['defer']()
    codeBlock = []
    lineCount = 0
    read.eachLine sewSrc[0], (codeline, last) ->
      lineCount++
      if (lineCount > blockLoc.start and lineCount <= blockLoc.end)
        #if we are reading from a block in the file
        codeBlock.push codeline
      if last
        #codeBlock.unshift "\n"
        extraction.resolve codeBlock
        return false
    @extractionPromises[sewSrc] = extraction.promise
