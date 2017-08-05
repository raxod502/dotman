# CLI specification

## Initial installation

Install Dotman on any operating system:

    $ curl https://raxod502.github.io/dotman | sh

## Boilerplate

General syntax:

    $ dotman [(-v | --verbose)...] <subcommand> [<arg>...]

Get help:

    $ dotman [--]help [<subcommand>]
    $ dotman [<arg>...] --help

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

    $ dotman local-set [<path> [<name>]]

Unset the local dotfiles repository:

    $ dotman local-unset [--all | <name>]

## Package management

Describe a target or task:

    $ dotman info <name>

Install a target:

    $ dotman install [--manual [--test | --no-test]] [--force]
                     (--all | (<name> [-- | <option>...])...)

Uninstall a target:

    $ dotman uninstall [--manual] [--force]
                       (--all | (<name> [-- | <option>...])...)

Reinstall a target:

    $ dotman reinstall [--force] (--all | (<name> [-- | <option>...])...)

Configure a target:

    $ dotman configure [--force] (--all | (<name> [-- | <option>...])...)

Unconfigure a target:

    $ dotman unconfigure [--force] (--all | (<name> [-- | <option>...])...)

Reconfigure a target:

    $ dotman reconfigure [--force] (--all | (<name> [-- | <option>...])...)

Update a target:

    $ dotman update (--all | (<name> [-- | <option>...])...)

Change an option, and reinstall or reconfigure as necessary:

    $ dotman option (<name> [-- | <option>...])...

Run a task:

    $ dotman run <name> [<option>...]

## System maintenance

Move a file or directory and update symlinks:

    $ dotman mv (<source> <target> | <source>... <directory>)

Perform Git operations on the dotfiles repository, detecting necessary
updates:

    $ dotman git [<arg>...]

Perform Git operations on the local dotfiles repository, detecting
necessary updates:

    $ dotman local-git [<arg>...]
