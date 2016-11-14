# Repo Master #

Script for traversing/working in git repos.

Coded on Mac OS X 10.11.6.

## What does it do? ##

1. Loads configuration...
2. Traverses through a filtered list of paths containing git repos
  - Determines whether repos should be skipped
  - Gives the user the option to start a shell in the current repo where they can run commands.

## Components ##

`Criteria` holds configuration information
  - what repos to ignore/track
  - configuration file/default configuration
  - add'l conditions for ignoring a repo

`FileFinder` creates an enumerable of paths which is iterated over in main program
  - includes `Find`
  - contains conditions which determine whether a path is skipped or not

`ShellWrapper` wrapper for running commands in a shell
  - can add functions which contain system commands from modules
  - `exec`-like functions use ruby `%x[ ]`
  - `shell`-like functions use ruby `system()`

`GitWrapper` module containing git commands
  - is provided to `ShellWrapper` instance

`what_today.rb` the main script to invoke

## How to use it? ##

Currently, the script traverses starting at the users's home directory.

At the command-line type:

```
ruby -I lib bin/what_today.rb
```

## Future Features ##

- Add command-line opts/args
- Add database for faster loading
- Add functions which will perform standard git commands on repos
- Stats for repos?
