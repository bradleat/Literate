---
Author: Bradley Leatherwood
Date: July 28, 2014
Email: bradleat@inkibra.com
...

# Introduction 
The `TOC` (Table of Contents) parser was much like the `CodeParser` in its design, it has now been stripped down and relies the outside modules `meta` for the bulk of its work. It's purpose is to look at a file and return an array of the locations refered to by the Table of Contents.

```YAML
---
Author: Bradley Leatherwood
Date: June 29, 2014
Email: bradleat@inkibra.com
TOC:
    - "[Weave](./src/controllers/Weave.md)"
...
```

In the above example, `TOC` denotes the start of the Table of Contents. This YAML formatted information is found at the top of the markdown files (however, there is no technical limitation to placing this informatino at that top of the `.md` files). 

## Module Purpose
The module exports the `class TOC` and is able to singularly parse a table of contents exposed by one `.md` file, or can `walkAndParse` the entire table of contents "tree". In either case it returns an array with the entries found during the parsing.

## Used By
- `src/controllers/Weave.coffee`

# Code and Contracts
## Module Start
#[TOC Includes]:(./src/parsers/TOC.coffee:Includes)

We need a promise interface, `RSVP`, a file system interface, `fs`, and the meta data extractor (that parses YAML) , `meta`.

#[constructor]:(./src/parsers/TOC.coffee:constructor)

The constructor of `TOC` was derived from the `CodeParser` model, but thanks to `meta` only needs to set up a `Promise` hash, and a `table` to store results found during a recursive table of contents walk.

#[Parsing]:(./src/parsers/TOC.coffee:parse)

`parse` simply reads the file given to it using `fs.readFile`, and precluding any errors uses `meta` to extract the `TOC` element encoded using YAML. For each entry we use the `capture` regex to *capture* the 
We remove the the extention of the filename, and define a `locations` array for the location of the files revealed by the Table of Contents search.
For instance in the above table of contents example, `(capture.exec entry)[2]` would return the string `"./src/controllers/Weave.md"`. `(capture.exec entry)[1]` isn't actually needed here. Before resolving the `Promise`, we push each of these found captures to an the `locations` array.


#[Walk]:(./src/parsers/TOC.coffee:walk)

`walkAndParse` is the part of the recursive parse routine that is actually supposed to be called by an outside entity. It simply waits for the first `parse` to finish, then waits for the entire recursive parse to finish (when `@walkPromises` has completed) before returning the `@table` containing all of the found table of contents entries to the caller.

The `recursiveParseStart` function is for class use only, and issues a new `@walkPromise` for each `parse` so that `walkAndParse` can be aware of its progress. The function adds any new found table of contents entries (entries that were not already found by a previous iteration) to `@table` and starts another `recursiveParseStart` for these locations.  

### For Helpers...
The `meta` helper (basically a stripped down version of `meta-marked`), returns to us the YAML object defined at the top of our markdown files. We then look for the `TOC` entry and "parse" the entries for the filenames (using the regex, `capture`). We add valid entries to the `locations` array. 








