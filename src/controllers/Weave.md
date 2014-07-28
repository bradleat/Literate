---
Author: Bradley Leatherwood
Date: July 28, 2014
Email: bradleat@inkibra.com
TOC:
    - "[TOC](./src/parsers/TOC.md)"
    - "[Code](./src/parsers/Code.md)"
...

# Introduction
The `WeaveController` is where we control the parsers and I/O operations needed to sew or weave a file or files into a literate document or book. The controller must be able to control sew's, and weave's (multi file sew operations) while handling source copying and *patch mode* (these modes are mutually exclusive): 

- `shouldCopySource` - copies source from the orgin location, to the final book folder (in `.code` and `.md` sub-directories).
- `patchMode` - updates a book's literate files, from the version of the source packed with the book (presumably this version was eddited, and should be treated as the *base* for the new literate document).

## Module Purpose
The class `WeaveController` is designed to control a single sew or weave operation (such as when it is called by the [Application Start][app] or by the [editor server service][editorService]). The module has a heaviy backing on the Promise pattern (as given by [RSVP](https://github.com/tildeio/rsvp.js)), the class exposes a promise, `WeavePromise` that can be used by the caller to complete an operation only after the entire weave is finished. For instance, the editor service, needs to know when a weave is finished, so it doesn't respond with partially completed weave text.

## Used By
- `app.coffee`
- `src/server/service/editor.coffee`

# Code and Contracts

## Module Start

#[Includes]:(./src/controllers/Weave.coffee:Includes)

We rely on node's `fs` module to read and write to files (as well as normalize file paths)
As previously mentioned, `RSVP`, helps us expose the promise pattern.
`Slash` converts Windows style file paths into unix-style file paths so other modules do not have to deal with multiple cases.
`mkdirp` makes the directories dictated by a certain file path, without forcing us to check for the current directory structure.
`invert` from lo-dash inverts the key and value of an object 
`extDecard` captures the non-extention and extention part of a filepath
`dirFromFile` captures the filepath and filename
[CodeParser][] Parses the `.code` file and returns a tree of the location of *literate block start indicators*.
[TOCParser][] Parses the `.md` files for Tables of Contents, and returns the files specified in the entries. The Parser can work recursively as well. 
[SeamController][] is responsible for joining the `.code` and `.md` files together after it has been given a `tree` from the `CodeParser` with *literate block start indicators*. The `SeamController` also can read `.md` file and return the list `.code` files indicated by the literate start block indicators.

#[WeaveController]:(./src/controllers/Weave.coffee:WeaveController)

The `WeaveController` starts by storing a `Promise` on `WeavePromise` so that some accessor can complete an operation after the weave is finshed. The controller unsets `shouldCopySource` if both `shouldCopySource` and `patchMode` were given as options, as the `patchMode` operation removes the need or want to also copy source. Furthermore, the controller makes sure that all file paths are in unix form using both the `file.normalize` and `slash` functions, it also starts an instance of `CodeParser` and `SeamController` for later use.

#[WeaveStart]:(./src/controllers/Weave.coffee:WeaveStart)

Still in the controller, we actually start a `weave` or `sew` operation with a call to `buildPage`. We also define `buildPromise` so subsequent operations can contiune after a build has completed. As you will see, a lot of this module's control flow is dicated by the `Promise` interface. 
If we are doing a `weave` then we also need to read through the Table of Contents and build each page that is returned from a walk of the Table of Contents, the block following the `if` statement takes care of that.

The next thing that actually happens (code wise) is that *wrap up* code is set that is to be run after every `buildPromise` has returned with a status. However, in the story of this module, the next thing that happens is not this, but instead the `buildPage` call with the `.md` file supplied as a parameter:

#[Build Start]:(./src/controllers/Weave.coffee:buildStart)

The `buildStart` sets a `buildPromise` so that we can get back to the *wrap up* code when it is time. After `seamstress` or the instance of the `SeamController` has returned to us a list of all `.code` file refered to in the supplied `.md` file. Before asking `codeParser` to parse these files for *literate block start indicators*, there is a check for being in patch mode. If `patchMode` is `true`, there is a bit of work to do:

Given that a project's directory structure might look something like this:

- app.js
- app.md
- book/
    + .code/
        * app.js
    + .md/
        * app.md
    + app.lit.md

Think about the way `app.md` would link to `app.js` with an *literate block reference*. `app.md` would expect to find `app.js` in the same directory as itself, there is an obvious problem that is presented in `patchMode`. That is, `app.md` now being found in *book/.md/app.md* should link to `app.js` something like this *book/.code/app.js* or `../.code/app.js`. We solve this problem, by making just that adjustment to the list of sources that the `seamstress` returns to us (using `@dest` in the place of "book"). We then additionaly create a `patchTree` that allows us to perserve the orginal information for later, so that the `SeamController` can find the `.code` files.

#[Code Parse]:(./src/controllers/Weave.coffee:codeParse)

After `codeParser` returns a `tree` of *literate block start indicators* from the code file(s) supplied to it, we have enough information (the name of the `.md` file, and the `tree` with the references) for the `SeamController` to return a `tangle`d version of the code (the literate document). 

#[After Tangle]:(./src/controllers/Weave.coffee:afterTangle)

After the tangle is done, the `.md` and `.code` source is copied to the `@dest` location. The `patchMode` tree is reversed, and then used to return the `source` array to its orginal form (the `resolve file: file, sources: sources` call which *resolves* the promise made at the begginning of the procedure, eventually leads to the compliation of a `book.json` document (more on this later), sufficed to say, this document expects the source's orginal location (and not the copied location that would be referenced in `patchMode`). 

The `dir` variable is meant to capture the directory from the filepath, so that when we later write the `tangle` to a file, `mkdirp` can make the directories for the files. After the the files are written, we `resolve` the promise (if there was an error during this write process, we `reject` the promise).

If all promises have been resolved, meaning every page of the `sew` or `weave` has been `tangle`d and all source has been copied (as applicable), the `book.json` file remains as the last thing to finalize. This wrap up code is set by the contructor, and runs after `RSVP.hash` reports that all build Promises have been completed. The `RSVP.hash` is called twice, as the first time it can return true if only the first `build` has been completed and no others have been inserted into the `Promise` hash. Calling it again, does the trick of getting all of the `buildPromises` included. However, this is somewhat of a trick, and better tracking of `Promises` upon revision should allow for this uncomfortable manuveur to be avoided.

#[Wrap Up]:(./src/controllers/Weave.coffee:WeaveWrapUp)

The `book.json` file consists of several objects named by the literate document page they represent (`app.lit.md` would be `app`). The objects have as values an array named `code` with all the `.code` files that are needed to construct the literate document, and an object named `md` with the markdown file needed to construct the literate document. The `md` object is not strictly needed (as its location should be implied from the location of the literate document), however it is redundantly included nonetheless. The `pressPagesToBook` call, does the job of saving this object to actual file on disk. After this is done, the orginal `WeavePromise` can be resolved by the caller.

## More on File Operations
As these operations are nothing more than trival file operations, they were not presented above. They will now be briefly covered.
### Press Page to Book 
`pressPageToBook` takes a book object as a parameter, attempts to read an existing `book.json` file. If that file is present, it combines the two objects then writes them to disk as `@dest/book.json`. If file isn't present or readable, it just writes the given object to disk as `@dest/book.json`
#[Press Page to Book]:(./src/controllers/Weave.coffee:pressPageToBook)
## Copying Source
Herein, we copy the file listed in *file* to the `@dest/.md/` directory and each file listed in sources to the `@dest/.code/` directory.
#[Copy Source]:(./src/controllers/Weave.coffee:copySource)
The following code is from the last part of the `buildPage` method and contains a similair `if dir?` if/else statement. For both `copySource` and this part of `buildPage`, the goal is to first build the directory component of the filepath, `file`, by using `mkdirp` to make the directory for the file if it exists. If it doesn't exist (the `else` branch), then we need to make sure the `@dest` location at leasts exists. After this part of the if/else, the code is identical (so after the `mkdirp` call in either part of the branch). In the case of `copySource`, it `pipe`s the `oldFile` to `newFile` and in the case of `buildPage`, it writes the tangle to the `newFile` `line` by `line`.
#[buildPage to File]:(./src/controllers/Weave.coffee:toFile)




