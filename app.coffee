##Includes#
argv = require('minimist')(process.argv.slice 2)
WeaveController = require './src/controllers/Weave'
server = require './src/server/base'
#todo: make the window smaller and feel more like a "page" <--- metaphorically
# this way we evoke more of the "ah this is a document metaphor feeling or whatever"

##Sew#
sew = (weave = false, patch = false) ->
  #source = argv._[1]
  #dest = argv._[2]
  if argv._[1]?     
    unless argv._[2]?
      argv._[2] = './book'
    new WeaveController argv._[1], argv._[2], weave, not (argv.nocopy? or argv.s?), patch 
  else 
    console.warn 'Error: missing filename for sew operation, type help for more information'

##Read#
read = (edit = false) ->
  #book.json = argv_[1]
  unless argv._[1]?
      argv._[1] = './book'

  if argv.edit? or argv.e? or edit
    (new server argv._[1], true).startService 'editor'
  else
    (new server argv._[1], true).startService 'preview'


##ModeSelection#
switch argv._[0]
  when 'weave' then sew true
  when 'sew'   then sew()
  when 'patch' then sew false, true
  when 'read'  then read()
  when 'edit'  then read true
  else console.log "Invalid input"
