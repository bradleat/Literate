---
Author: Bradley Leatherwood
Date: July 28, 2014
Email: bradleat@inkibra.com
...

# Introduction 
The `CodeParser` finds the *literate block start indicators* in the code, and returns a `tree` object with the locations of all found blocks in the file.The returned Trees have the following format:

```coffee
  @tree:
    `filename`:
      `BLOCKNAME`:
        refCount: #To track references to block in markdown, unused
        start: #STARTING_LINE_NUMBER
        end: #ENDING_LINE_NUMBER
```

## Module Purpose
The module is built for use by the `WeaveController` with the goal to make it very extensible to use by different languages by including a easily swapable `_lexical` grammar definitions. The default parsing grammar is for CoffeeScript, but at some later point in time, adding seperate language parsing grammar definitions will be possible.

#[Grammar Definitions]:(./src/parsers/Code.coffee:lexical)

The two regex `blockbegin`, `blockend`, and the string `lang` are all defined on the instance. `blockbegin` captures statements such as:
(CoffeeScript)
```coffee
##lexical#
```
or (JavaScript)
```js
//#lexical#
```
The `BLOCKNAME` in each of these cases is "lexcial".

The `blockend` regex matches statements when the `BLOCKNAME` would be "end".

The `lang` is just the name of the language that the is being defined. All, in all this scheme is very simple, but allows us adequete power to do what we need to do.

## Used By
- `src/controllers/Weave.coffee`

# Code and Contracts
## Module Start

#[Code Includes]:(./src/parsers/Code.coffee:Includes)

We need a promise interface, `RSVP`, a file system interface, `fs`, and the `BlockParser` (that will later be used to support sub-blocks ).

#[constructor]:(./src/parsers/Code.coffee:constructor)

The constructor of `CodeParser` simply sets up a `BlockParser`, calls the `@_lexical` function to setup the parsing grammar, and starts an empty `@tree` for the parsing results.

#[Parsing]:(./src/parsers/Code.coffee:parse)
`parse` uses the `state` object to track the current progression of the parse for any single file (whereas the `tree` object can store the results of multiple files worth of parsing). The `state.tree` object is the object that will be stored to `tree.FILENAME` after the instance if finished parsing a file. 
`state.ExplicitEnded` is used by `BlockParser` whenever a the "#end#" statement is matched by `@blockend`. In the same fashion, `state.blockdepth` and `state.blockTrace` track the depth of sub-blocks that have been entered, and `blockTrace` traces the history of entering `sub-blocks`. However, at current time this behavior is not offically supported or tested. `state.line` tracks the line that we are reading of the current file.

Orginally, `parse` used `line-reader` (which can be found on npm) to read the line of the `.code` file to be parsed (by line), but due to poor error handling was abandoned. However, the structure of the code is very much influenced by the orginal use of `line-reader`. 

After `fs.readFile` is used to read the `.code` file (and assuming there is no error reading the file), the file is split to an array by the line ending '\n'. The last line of the array, is copied to `last` using a CoffeeScript destructuring assignment. 

This allows us to then use a `line-reader` like interface to parse the file by line. For each `line` of the file, we increment the line counter, `state.line` and use the regex expressions `blockend` and `blockbegin` to test for the end and start of a block. Notably, the `blockend` is tested first as a `blockbegin` regex would also match at `blockend`. 

A `blockend` match, launches the blockParser's `onExplicitEndToken` routine (and generates a warning for the user), while a `blockbegin` match, results in a the `onBeginToken` routine being called with the captured `blockname` and `state`. The `blockParser` makes the `tree` entry for the block using the format seen above.

If we are on the last line of the parse we do not search, we finish by adding the language of the `CodeParer` to `state.tree`, record the last open block as being ended, and finally move the `state.tree` to the master `tree` object under the current `filename`. 










