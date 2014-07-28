welcome to the todo parser

it should:
parse code files and md files for:

```coffee
 #todo: [text here]


```

```js
//todo: [text here]
```

```md
> todo: [text here]

```

- it should allow us to define more "todo" words, such as Checkout
- it should give each todo a uid (in both the source, and the todos.lit.md)
- it should move each todo into some file called ./todos.lit.md (for instance)
- there should be some tool to:
    + remove todo's from the source from the cmd line (todo clean?)
    + mark todo's as complete (YAML?)
    + view todo's in the browser for the current files (or the entire book)
        * remove todo's from the source from here
        * mark todo's as complete
- we need to value todos.lit.md's version of todo above the other versions
    + perhaps use a section of book.json for this

> TODO: online "book viewer as well", it should show some sort of view on book.json, perhaps displaying a readme.lit.md file (a readme.md file with a TOC included).
> thought: readme files should be able to be at each directory level. so if you are viewing for instance app/sew.lit online, you can easily view the readme at app/readme.lit (in that the book viewer automatically/readily show us it to us). 


> Checkout: https://www.npmjs.org/package/asset-rack

> todo: rename file tool (tries to do it with git if available)
> todo: rename reference tool
>   - propogate rename mode (after you just rename reference in a file)
>   - rename -to -from
> thought: have some sort of automatic "debuger" of failed, "Weaves", to help you correct reference error, then fuck the rename reference tool! this is easier and more elegant
> the debugger tool should help out when designing something to process syntax like this:
> #should: move `TOCWalk` to ./parsers/Parser ... #should
> ... it can prompt you to go ahead a move the code, then help you debug what should be fixed
> todo: move file tool (tries to do it with git if available)
> todo: literate coverage tool
> Think: PatchMode with 100% coverage is for patching, Development mode is kinda how we have the Project dir with -> src and then an old book. We then need to make the coverage tool allow us to mark .md and .code files as "literate"
> todo: a file generator from a template (make .md and .code file templated a sort of way... thing mustache or handlebars code templating, or the YoMan thingy )
> class and function (automatic grabbing)... so imagine 


- Introduction to Module
- Used For
- Used By
- Code and Contracts