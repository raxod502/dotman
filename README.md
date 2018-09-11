**Dotman**: one package manager to rule them all.

## Idea

When setting up a new machine, there is a lot to do. You need to
install all your packages, symlink your dotfiles, set up your
application preferences, perform system administration tasks, and
install all those little hacks that you did once upon a time to fix
things but no longer remember.

Wouldn't it be great if you had some software that could do that all
for you? Enter Dotman. With Dotman, you encode your system
administration tasks into a set of virtual "packages", each defined as
a simple Python script with some metadata. A package can represent
software that should be installed, configuration files that should be
symlinked, some one-off script that should be installed, or anything
else that you can program in Python.

What does Dotman get you over a simple collection of scripts? Firstly,
Dotman provides a library of useful utility functions like "make sure
version X of Homebrew package Y is installed with option Z enabled",
so that writing your own packages is as quick and easy as possible (if
it's not easy, who ever bothers to do it?). Secondly, Dotman allows
you to define named "groups" of packages, and it keeps track of which
packages are already "installed". That way, you can simply ask it to
get your machine ready for some Ruby development in Emacs, and if
you've already had it installed Ruby then it won't do that again
(unless you ask it to double-check the dependencies).

## Setup

On a new machine, you'll have a couple of steps to get everything
running from scratch:

* Install the operating system and get connected to the Internet.
* Install Git and clone your Dotman configuration.
* Install Python and then install Dotman using Git+Pip.
* Ask Dotman to use your configuration to set up the rest of the
  system as desired.

## Configuration format

A Dotman configuration is a directory, probably a Git repository, with
a subdirectory called `packages`. The `packages` subdirectory has a
number of Python scripts, with script `configure_emacs.py`
corresponding to a package called `configure-emacs` for example.

Package metadata is defined by setting global variables in the script,
for example:

    DESCRIPTION = "Symlink Emacs dotfiles."
    DEPENDENCIES = ["emacs", "dotfiles"]

Then to describe what should happen when the package is installed, you
define a global `install()` function. It's that simple!

Helpful functions like `install_homebrew_package` can be obtained by
importing the `dotman` module.

## Usage

The main command is `dotman install`, which takes a list of packages
whose scripts should be run. The `-u` or `--upgrade` flag causes the
scripts to be run in "upgrade mode"; `dotman upgrade` is an alias for
`dotman install -u`.

Packages are skipped if they were installed already by Dotman (or, for
`-u`, if they were upgraded in the last 24 hours). This can be
overridden by the `-f` or `--force` flag. The same can be achieved for
dependencies of the named packages with the `-F` or `--force-all`
flag.
