convert = require 'marked'
{noMeta} = require '../../helpers'
{extDecard} = require '../../helpers'
  
fs = require 'fs'

module.exports = (book, filepath, query, cb) ->
  if query.mode is'code'
    filepath = "#{book.dir}/.code/#{book[filepath].code[0]}"
  else if query.mode is 'markdown'
    filepath = "#{book.dir}/.md/#{filepath}.md"
  else
    filepath = "#{book.dir}/#{filepath}.lit.md"

  fs.readFile filepath, {encoding: 'utf8'}, (err, data) ->    
    if err?
      cb err
    else
      unless query.mode is 'code'
        cb null, {md: data, html: convert noMeta data} 
      else
        cb null, {code: data, type: (extDecard.exec filepath)[2]}


    

