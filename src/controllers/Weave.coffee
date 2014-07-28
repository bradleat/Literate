#todo: you should be able to specify 

##Includes#
fs = require 'fs'
RSVP = require 'rsvp'
path = require 'path'
slash = require 'slash'
mkdirp = require 'mkdirp'
{invert} = require 'lodash'
{extDecard} = require '../helpers'
{dirFromFile} = require '../helpers'

CodeParser = require '../parsers/Code'
TOCParser = require '../parsers/TOC'
SeamController = require './Seam'


##WeaveController#
module.exports = class WeaveController
  
  constructor: (startFile, @dest, recursive = false, @shouldCopySource = false, @patchMode = false) ->
    #todo: make an option for recursive, @shouldCopySource, @patchMode and include a verbose mode
    @WeavePromise = new RSVP.Promise (resolve, reject) =>
      #Annouce the `options` to the `console`
      console.log "Weave Controller: started:"
      console.log "Recursive: #{recursive}"
      console.log "Patch Mode: #{@patchMode}"
      #If @shouldCopySource and @patchMode are both `true`, we have a conflict.
      if @shouldCopySource and @patchMode
        @shouldCopySource = false
        console.log "Cannot copy sources in Patch Mode... resuming"
      console.log "CopySource: #{@shouldCopySource}"

      #Convert our file names to a standard format using *slash*
      @dest = path.normalize @dest
      @dest = slash @dest 
      @startFile = path.normalize @startFile
      @startFile = slash @startFile   
      
      #We need these...
      @codeParser = new CodeParser
      @seamstress = new SeamController

      ##WeaveStart#
      @buildPromise = {}
      @buildPage startFile
      
      #We only need this if we are doing a recursive walk
      if recursive
        @tocParser = new TOCParser
        @tocParser.walkAndParse(startFile).then (table) =>
          @buildPage page for page in table
      
      
      ##WeaveWrapUp#
      RSVP.hash(@buildPromise).then (pages) =>
        return RSVP.hash @buildPromise
      .then (pages) =>
        console.log "Building book.json file"
        book = {}
        for i, page of pages
          book[page.file] =
            code: page.sources
            md: "#{page.file}.md"
        return @pressPagesToBook book
      .then (book) ->
        resolve book

  
  ##buildStart# 
  buildPage: (file) ->
   
    #Cleaning up file name
    file = path.normalize file
    file = slash file

    console.log "Building #{file}'s literate page"
    @buildPromise[file] = new RSVP.Promise (resolve, reject) =>
    
      @seamstress.prepareFile(file).then (sources) =>
        ##codeParse#
        #Option handling...        
        if @patchMode #transcribes the sources for patch mode
          patchTree = {}
          for source, i in sources
            sources[i] = "#{@dest}/.code/#{source}"
            patchTree[source] = sources[i]
        @codeParser.parse(sources[0])
        .catch (err) =>
          console.warn "#{err.text} while on #{file}"
          reject err
        .then (tree) =>
          #TODO: 'maintain the lit-er project in book format', but build a literate coverage tool first
          return @seamstress.sewFile file, tree, (patchTree if patchTree?)
        .then (tangle) =>
          ##afterTangle#
          #Option handling
          @copySource file, sources if @shouldCopySource
          #Gets rid of the file extension
          file = extDecard.exec file
          file = file[1]
          if @patchMode
            patchTree = invert patchTree
            for source, i in sources
              sources[i] = patchTree[source]
            file = file.replace "#{@dest}/.md/", ''
          else
            dir = dirFromFile.exec file #capture filepath directory
          ##toFile#
          if dir? #file path has a directory component
            mkdirp "#{@dest}/#{dir[1]}", (err) =>
              if err?
                reject err
              else
                newFile = fs.createWriteStream "#{@dest}/#{file}.lit.md"
                newFile.on 'error', => 
                  reject new Error "#{file}.lit.md Write Error"
                for line in tangle
                  newFile.write line
                newFile.end()
              resolve file: file, sources: sources
          else #file path does not have a directory component
            mkdirp "#{@dest}", (err) =>
              if err?
                @buildPromise[file].reject err 
              else
                newFile = fs.createWriteStream "#{@dest}/#{file}.lit.md"
                newFile.on 'error', =>
                  reject new Error "#{file}.lit.md Write Error"
                for line in tangle
                  newFile.write line
                newFile.end()

              resolve file: file, sources: sources

  ##pressPageToBook#         
  pressPagesToBook: (book) ->
    #Attempt to read existing book file
    Promise = new RSVP.Promise (resolve, reject) =>
      fs.readFile "#{@dest}/book.json", {encoding: 'utf8'}, (err, data) =>
        unless err?
          try
            oldBook = JSON.parse data
          catch
            oldBook = {}
            console.warn "Invalid book.json file found in the destination directory, #{@dest}"
        else
          oldBook = {}
          console.warn "No existing book.json file found in the destination directory, #{@dest}"
        #Cleaning up file name
        file = path.normalize file
        file = slash file
        
        for key, entry of oldBook
          unless book[key]?
            book[key] = entry


        #Writing to the book file  
        bookWriter = fs.createWriteStream "#{@dest}/book.json"
        bookWriter.on 'error', -> 
          reject new Error 'Book.json Write Error'
        bookWriter.write JSON.stringify book, null, 4
        bookWriter.end()
        resolve book


  ##copySource#
  copySource: (file, sources) ->
    #todo: only copy once, use promises, get rid of redudnat code
    mdFile = file
    #Gets rid of the file extension
    file = extDecard.exec file
    file = file[1]
    console.log "Copying source for #{file}.lit.md "
    #Write 
    for src in sources
      dir = dirFromFile.exec src
      if dir? #file path has a directory component
        mkdirp "#{@dest}/.code/#{dir[1]}", (err) =>
          console.warn err if err?
          oldFile  = fs.createReadStream src
          newFile = fs.createWriteStream "#{@dest}/.code/#{src}"
          oldFile.pipe newFile
          newFile.on 'error', -> console.warn ".code/#{src} Write Error on copy while on #{file}"
          oldFile.on 'error', -> console.warn "#{src} Read Error on copy while on #{file}"
      else #file path does not have a directory component
        mkdirp "#{@dest}/.code/", (err) =>
          console.warn err if err?
          oldFile  = fs.createReadStream src
          newFile = fs.createWriteStream "#{@dest}/.code/#{src}"
          oldFile.pipe newFile
          newFile.on 'error', -> console.warn ".code/#{src} Write Error on copy while on #{file}"
          oldFile.on 'error', -> console.warn "#{src} Read Error on copy while on #{file}"
    
    dir = dirFromFile.exec file
    if dir? #file path has a directory component
      mkdirp "#{@dest}/.md/#{dir[1]}", (err) =>
        console.warn err if err?
        oldFile  = fs.createReadStream "#{file}.md"
        newFile = fs.createWriteStream "#{@dest}/.md/#{file}.md"
        oldFile.pipe newFile
        newFile.on 'error', -> console.warn ".md/#{file}.md Write Error on copy while on #{file}"
        oldFile.on 'error', -> console.warn "#{file}.md Read Error on copy while on #{file}"
    else #file path does not have a directory component
      mkdirp "#{@dest}/.md/", (err) =>
        console.warn err if err?
        oldFile  = fs.createReadStream "#{file}.md"
        newFile = fs.createWriteStream "#{@dest}/.md/#{file}.md"
        oldFile.pipe newFile
        newFile.on 'error', -> console.warn ".md/#{file}.md Write Error on copy while on #{file}"
        oldFile.on 'error', -> console.warn "#{file}.md Read Error on copy while on #{file}"



