\Register a dotfiles repository, and optionally select it:

    $ dotman register [--select | --no-select] [<path> [<name>]]

Deregister a dotfiles repository:

    $ dotman deregister [--all | <name>]

Rename a dotfiles repository:

    $ dotman rename [<old>] <new>

Select a dotfiles repository:

    $ dotman select [<name>]

Deselect a dotfiles repository:

    $ dotman deselect [<name>]

Get information about software:

    $ dotman info <name>

Install software:

    $ dotman install <name>

Uninstall software:

    $ dotman uninstall <name>

Update software:

    $ dotman update <name>

Configure software:

    $ dotman configure <name>

Undo configuration of software:

    $ dotman unconfigure <name>

Run a generic task:

    $ dotman run <name>

Debug software installation and configuration:

    $ dotman debug <name>
