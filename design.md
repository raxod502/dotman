# Conceptual design

Configuration of Dotman is done through a single map literal with no
embedded code. That is, the configuration is *purely declarative*.
User-specific code can be added by creating additional Ruby files and
referencing them as string literals in the configuration map.

## Top-level configuration

The top-level configuration map has a `:components` key, which is a
map of component names to components.

## Components

A *component* is a collection of *targets* together with some
associated metadata. Each component has a *name*.

## Target

A *target* is a collection of *operations* together with some
associated metadata. Each target has a *name*.

For example, one might define a target that installs a software
package and sets up associated parts of the system for it.

## Operation

An *operation* is an abstract representation of some transformation on
the system. It must be able to be run forward, but it may also
optionally be able to be run backward, and possibly forward in
*upgrade mode*.

An operation has a *name*, optional *arguments*, and optional
additional *configuration*.

Alternatively, an operation may be a *wrapper operation*, meaning that
it will have a name, arguments, configuration, and also nested
operations.

For example, one might define an operation that can install,
uninstall, and upgrade a package using the system package manager.

## States and targets

What can we do with components?

* run them - this
* install them
* configure them
* upgrade them
* reinstall and/or reconfigure them
* uninstall and/or unconfigure them
