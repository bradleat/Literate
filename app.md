---
Author: Bradley Leatherwood
Date: July 25, 2014
Email: bradleat@inkibra.com
TOC:
    - "[WeaveController](./src/controllers/Weave.md)"
...

# Introduction

This is our program start location. There are **X** primary modes of operation for inKibra Lit-er:

- *Sewing* together seperate `.code` and `.md` files into a *literate* document.
    + We can recursively `sew`, which is called a `weave`
- *Code Coverage, Publication, and Quality*: Information about code quality concerns available in the command line or browser:
    + Publication tools:
        * Warnings on large diff's from *publication date* to *current date* as an indicator that the `.code` and `.md` documents might not be in sync
        * Mismatched publication dates between `.code` and `.md` files
        * Authorship history tracking 
        *  Todos: Store, remove, and track "todos" and other such notes left in source
    + Coverage exposes: 
        * Files without a `.md` or `.code` pair
        * Files without testing, benchmarking, 
    + Test and Benchmark Information
        * Slow benchmarks
        * Failed Tests
        * Failed Linting
- `Read` We can then run this book as a documentation server that is able to:
    + Download a literate book (pdf) for download 
    + Run live benchmarks, and tests (for benchmarks and tests written in CoffeeScript) on the Server or Browser
    + Track Todos

## More on Testing and Benchmarking
We expose a wrapping syntax around test and benchmarking libraries, so that tests can be embedded in *literate* documents. *The wrapping of the tests is done in JavaScript or CoffeeScript, however any language may be targeted*

## Module Purpose
This module is designed to handle command line instructions from the user. The module then starts the service (for instance a `weave`).

- `sew` - Joins `.code` and `.md` files together into a literate document
    + `weave` - or *rescursive sew*, follows the [Table of Contents][TOC], sewing each file found.  
    + *Override copying of source* - stops copying of the source into the destination directory
    + *Patch Mode* - updates a book's literate files, from the version of the source packed with the book
- `read` - Launches a preview server to read the book in the browser
    + 'edit' - Allows the book to be edited from the browser

# Code and Contracts

## App Start
We currently use [minimist.js](https://github.com/substack/minimist) to parse command line arguments. 
#[Includes]:(app.coffee:Includes)
We additionally need to require the `WeaveController` and the `Server` so that we can support the following commands:

- *Sewing commands* `weave`, `sew`, `patch`
- *Read commands* `read`, `edit`  

#[ModeSelection]:(app.coffee:ModeSelection)

As we can see, there are two groups of commands, those that result in a `sew` call, and those that result in a `read` call.

#[Read]:(app.coffee:Read)

The `read` calls simply starts the server in either *editor* or *preview* mode, and verified location to the server. The user can specify a *read in editting mode* with the flags `--edit`, `-e`, or with the alias `edit`.

### Read Contracts
The `read` function (should) ensure that the `argv.[1]` variable actually refers to a valid book.json vile.

#[Sew]:(app.coffee:Sew)

The `sew` call simply starts the `WeaveController` with the approriate options, if the `source` location is valid. The `weave` option specifies a *rescursive sew* by following the [Table of Contents][TOC] from the `source` file. `--nocopy` or `-s` flags specify that the `WeaveController` **should not** copy the source, which is its default behavior.

### Sew Contracts
The `sew` function (should) ensure that the `argv_[1]` variable actually refers to a valid `.md` file. It does not need to resolve `shouldCopySource` and `PatchMode` conflicts, as this is dealt with by the [WeaveController][].

