#Thanks to http://javascriptweblog.wordpress.com/2011/08/08/fixing-the-javascript-typeof-operator/
exports.typeOf = typeOf = (obj) ->
  ({}).toString.call(obj).match(/\s([a-zA-Z]+)/)[1].toLowerCase()

#Thanks to meta-marked

yaml = require 'js-yaml' 

splitInput = (str) ->
	return if str.slice 0, 3 is not '---'

	matcher = /\n(\.{3}|-{3})/
	metaEnd = matcher.exec str
	return metaEnd && [str.slice(0, metaEnd.index), str.slice metaEnd.index+5]

exports.meta = metaMarked = (src, opt, callback) ->
	mySplitInput = splitInput src 

	if mySplitInput?
		return yaml.safeLoad mySplitInput[0]
	else
		return null

exports.noMeta = noMeta = (src, opt, callback) ->
	mySplitInput = splitInput src
	if mySplitInput?
		return mySplitInput[1]
	else
		return null

#extDiscard
exports.extDecard = /(.+)\.(.+)/ #allows us to discard the extension


exports.dirFromFile = /(.+)\// 
		





