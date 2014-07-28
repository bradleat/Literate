module.exports = class CodeBlockParser
  constructor: () ->
  onBeginToken: (blockname, state) ->
    console.log "Parsing #{blockname} block from #{state.filename}"
    if blockname[0] == "." # enters sub-block level
      state.blockdepth++ #increasing depth
      state.blockTrace.push blockname
    else if blockname[0] == ".." # exits sub-block level
      if state.blockdepth < 1
        throw (
          "#{state.lang} Parse Error: #{blockname} has no Sub-Block
          to exit at line #{state.line} in #{state.filename}!")
      state.blockTrace.pop()
      state.blockdepth--
    else
      [..., last] = state.blockTrace
      state.tree[last]?.end = state.line-1
      state.blockTrace.push blockname

      #Enter our block into the parse tree
      state.tree[blockname] =
        refCount: 0
        start: state.line
        end: null
        sub: null
  
  onExplicitEndToken: () ->
    state.tree[state.blockTrace.pop()].end = state.line
    state.blockdepth--
    state.ExplicitEnded = true
    console.log "Parse Warning: Explicit End at Line #{@_.line}
    in #{@_.filename}"

