# CLI specification

## Initial installation

Install Dotman on any operating system:

    $ curl https://raxod502.github.io/dotman | sh

## Boilerplate

General syntax:

    $ dotman [(-v | --verbose)...] <subcommand> [<arg>...]

Get help:

    $ dotman [<arg>...] [--]help [<arg>...]

Get the version:

    $ dotman [--]version

## Repository registration

Register a dotfiles repository, and optionally select it:

    $ dotman register [--select | --no-select] [<path> [<name>]]

Deregister a dotfiles repository:

    $ dotman deregister [--all | <name>]

Rename a dotfiles repository:

    $ dotman rename [<old>] <new>

Select a dotfiles repository:

    $ dotman select [<name>]

Deselect a dotfiles repository:

    $ dotman deselect [<name>]

Set the local dotfiles repository:

    $ dotman set-local [<path> [<name>]]

Unset the local dotfiles repository:

    $ dotman unset-local [--all | <name>]

## Package management

Describe a target or task:

    $ dotman info <name>

Install a target:

    $ dotman install [--manual [--no-test]] [--force]
                     (--all | <name> [<option>...] | <name>...)

Uninstall a target:

    $ dotman uninstall [--manual] [--force] (--all | <name>...)

Reinstall a target:

    $ dotman reinstall [--force] (--all | <name> [-- | <option>...]
                                        | <name>...)

Configure a target:

    $ dotman configure [--force] (--all | <name> [-- | <option>...]
                                        | <name>...)

Unconfigure a target:

    $ dotman unconfigure [--force] (--all | <name> [-- | <option>...]
                                          | <name>...)

Reconfigure a target:

    $ dotman reconfigure [--force] (--all | <name> [-- | <option>...]
                                          | <name>...)

Update a target:

    $ dotman update (--all | <name> [-- | <option>...] | <name>...)

Change an option, and reinstall or reconfigure as necessary:

    $ dotman option <name> [-- | <option>...]

Run a task:

    $ dotman run <name> [<option>...]

## System maintenance

Move a file or directory and update symlinks:

    $ dotman mv (<source> <target> | <source>... <directory>)

Perform Git operations on the dotfiles repository, detecting necessary
updates:

    $ dotman git [<arg>...]
