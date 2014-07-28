convert = require 'marked'
{noMeta} = require '../../helpers'
{extDecard} = require '../../helpers'
SewController = require '../../controllers/Seam'
  
fs = require 'fs'



module.exports = (book, filepath, query, data, cb) ->
  if query.mode in ['code', 'markdown'] and filepath?
    if query.mode is 'code'
      filepath = "#{book.dir}/.code/#{book[filepath].code[0]}"
    else if query.mode is 'markdown'
      filepath = "#{book.dir}/.md/#{filepath}.md"
    fs.writeFile filepath, data.edit, {encoding: 'utf8'}, (err, data) ->    
      if err?
        cb err
      else
        cb null, 200
  else if query.mode is 'render'
    try 
      #todo- only respond when we are finished rendering!
      new SewController "#{book.dir}/.md/#{filepath}.md", book.dir, false, false, true
      cb null, 201
    catch
      cb "render error", 404


  else
    cb null, 404



    

