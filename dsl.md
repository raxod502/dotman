# DSL specification

To configure Dotman, place a file called `Dotfile.rb` at the root of
your dotfiles repository. When `dotman` is invoked from the command
line, the DSL definitions will be loaded and then `Dotfile.rb` will be
executed. The resulting data structures will be examined to determine
the appropriate actions to take from there.

## DSL elements

The top level of `Dotfile.rb` should contain some number of calls to
the `target` and `task` DSL elements. These may optionally be wrapped
in `with_os` blocks.

### `target`

    target 'NAME' do
      METHOD...
    end

Define a piece of software that can be installed and, optionally,
configured.

#### Takes methods

* `desc`
* `homepage`
* `min_version`
* `option`
* `test`
* `install`
* `configure`
* `target`
* `task`

#### Usable in

* top level
* `target`
* `task`

### `task`

    task 'NAME' do
      METHOD...
    end

Define a system administration task.

#### Takes methods

* `desc`
* `homepage`
* `min_version`
* `option`
* `run`
* `target`
* `task`

#### Usable in

* `target`
* `task`

### `desc`

    desc 'DESCRIPTION'

Provide a short description of a piece of software or a task.

#### Usable in

* `target`
* `task`

### `homepage`

    homepage 'URL'

Provide a link to the homepage of a piece of software.

#### Usable in

* `target`
* `task`

### `min_version`

    min_version 'VERSION'

Provide a default value for the minimum version of a binary or package
that must be installed.

#### Usable in

* `target`

### `option`

    option 'NAME'

Declare an option that can configure the installation of the target.
If `NAME` starts with `no-`, then the option is enabled by default.
Otherwise, it is disabled by default.

#### Usable in

* `target`
* `task`

### `test`

    test do
      METHOD...
    end

Provide some heuristics to check if software is already properly
installed. These are used to perform sanity checks if the user wants
to tell Dotman that they already installed some software manually.

#### Takes methods

* `binary`

* `block`
* `script`

* `depends_on`
* `depends_on_configured`

* `temporarily_moving`
* `with_option`
* `without_option`
* `with_os`

#### Usable in

* `target`

### `install`

    install do
      METHOD...
    end

Provide instructions on how to ensure that software is installed.

#### Takes methods

* `brew`
* `cask`
* `pacman`
* `yaourt`

* `remove`
* `symlink`
* `template`
* `touch`

* `block`
* `script`

* `depends_on`
* `depends_on_configured`

* `hints`

* `temporarily_moving`
* `with_option`
* `without_option`
* `with_os`

#### Usable in

* `target`

### `configure`

    configure do
      METHOD...
    end

Provide instructions on how to ensure that software is correctly
configured.

#### Takes methods

Same as `install`.

#### Usable in

* `target`

### `run`

    run do
      METHOD...
    end

Provide instructions on how to accomplish some system administration
task.

#### Takes methods

Same as `install`.

#### Usable in

* `task`

### `binary`

    binary 'NAME' [, ARGS...]

Assert that a binary is available, optionally of a minimum version.

#### Takes arguments

* `min_version`: a string specifying the minimum version to require,
  or nil. If this is non-nil, then the executable will be invoked with
  `--version`; otherwise, it will only be checked whether it is on the
  PATH. Specifying nil is useful if `min_version` was given at the
  `target` level.
* `subcommand`: a string or array specifying the subcommand to use to
  get the version, instead of `--version`.
* `skip_prefix`: a regex specifying a prefix of the version output to
  skip. This is useful for applications like Hub (which outputs the
  version of Git before its own version).
* `returns_nonzero`: true means that a non-zero exit code when getting
  the version is not an error.

#### Usable in

* `test`

### `block`

    block { BLOCKS... }

Run some custom Ruby code as part of an installation, configuration,
or other task. The code is split into multiple blocks so it can be
called intelligently by Dotman in the same way that Dotman manages
package managers, symlinking, and other tasks.

#### Takes arguments

The argument is a map of keywords to procs. All except `:run` are
optional. One can also pass a single block, to specify just `:run`.

* `:check`: return false only if the code actually needs to run. This
  block should not perform any potentially destructive actions.
* `:run`: perform the main task.
* `:update`: attempt to perform an update. This is only available in
  an `install` block.
* `:unrun`: if possible, perform the opposite of the `:run` block. For
  example, instead of creating a symlink, delete it (provided that
  it's linked to the expected file).

In `test`, this method instead takes a single block, for `:check`.

#### Usable in

* `test`
* `install`
* `configure`
* `run`

### `script`

    script { SCRIPTS... }

Run some custom external code as part of an installation,
configuration, or other task. The code is split into multiple scripts
so it can be called intelligently by Dotman in the same way that
Dotman manages package managers, symlinking, and other tasks.

#### Takes arguments

The argument is a map of keywords to filenames or arrays. All except
`:run` are optional. One can also pass a single filename, to specify
just `:run`.

The arguments have the same meaning as in `block`, except that
`:check` should exit non-zero when the code needs to run, rather than
returning false.

In `test`, this method instead takes a single filename or array, for
`:check`.

#### Usable in

* `test`
* `install`
* `configure`
* `run`

### `depends_on`

    depends_on 'TARGET' [=> :TYPE]

Declare a dependency on another target being installed.

#### Takes arguments

* `TARGET`: the name of another target defined in the same file. This
  must be a target, not a task.
* `TYPE`: the dependency type. This can be `:required` (the default,
  if it is omitted), `:recommended`, or `:optional`.

#### Usable in

* `install`
* `configure`
* `run`

### `depends_on_configured`

    depends_on_configured 'TARGET' [=> :TYPE]

Declare a dependency on another target being configured (and on it
being installed, implicitly).

#### Takes arguments

Same as `depends_on`.

#### Usable in

* `install`
* `configure`
* `run`

### `temporarily_moving`

    temporarily_moving 'FILE' do
      METHODS...
    end

Cause a file to be temporarily relocated for the duration of the
methods in the body. The allowable methods are the same as in the
surrounding scope.

#### Usable in

* `test`
* `install`
* `configure`
* `run`

### `with_option`

    with_option 'NAME' do
      METHODS...
    end

Cause some methods to only be run when a particular option is enabled.
The allowable methods are the same as in the surrounding scope.

#### Usable in

* `install`
* `configure`
* `run`

### `without_option`

    without_option 'NAME' do
      METHODS...
    end

Cause some methods to only be run when a particular option is
disabled. The allowable methods are the same as in the surrounding
scope.

#### Usable in

* `install`
* `configure`
* `run`

### `with_os`

    with_os :NAME do
      METHODS...
    end

Cause some methods to only be run on a particular operating system or
class of operating systems. The allowable methods are the same as in
the surrounding scope.

#### Usable in

* top level
* `install`
* `configure`
* `run`

### `brew`

    brew 'PACKAGE' [, ARGS...]

Install a package from Homebrew.

#### Takes arguments

* `flags`: the flags to require for the installation, e.g. `--devel`.
* `min_version`: the minimum version to require, if different from the
  `target`-level `min_version`.
* `tap`: the Homebrew tap to install from, e.g. `raxod502/radian`.

#### Usable in

* `install`
* `configure`
* `run`

### `cask`

    cask 'PACKAGE'

Install an application from Homebrew Cask.

#### Usable in

* `install`
* `configure`
* `run`

### `pacman`

    pacman 'PACKAGE' [, ARGS...]

Install a package from Pacman.

#### Takes arguments

* `min_version`: the minimum version to require, if different from the
  `target`-level `min_version`.

#### Usable in

* `install`
* `configure`
* `run`

### `yaourt`

    yaourt 'PACKAGE' [, ARGS...]

Install a package from Yaourt.

#### Takes arguments

* `min_version`: the minimum version to require, if different from the
  `target`-level `min_version`.

#### Usable in

* `install`
* `configure`
* `run`

### `remove`

    remove 'FILE'

Ensure that a file does not exist.

#### Takes arguments

The target path is relative to the home directory.

#### Usable in

* `install`
* `configure`
* `run`

### `symlink`

    symlink 'SOURCE' [=> 'TARGET']

Ensure that a symlink is created and valid.

#### Takes arguments

The source path is relative to the dotfiles directory. The target path
is relative to the home directory, and defaults to the basename of the
source path.

#### Usable in

* `install`
* `configure`
* `run`

### `template`

    template 'SOURCE' [=> 'TARGET']

If the target file does not exist, make it a copy of the source file.

#### Takes arguments

The source path is relative to the dotfiles directory. The target path
is relative to the local dotfiles directory, and defaults to the
basename of the source path.

#### Usable in

* `install`
* `configure`
* `run`

### `touch`

    touch 'FILE'

If the target file does not exist, create it. This is like `template`,
but with an empty source file.

#### Takes arguments

The target path is relative to the local dotfiles directory.

#### Usable in

* `install`
* `configure`
* `run`

### `hints`

    hints <<-EOS.undent
      TEXT...
    EOS

Register some explanatory text to display to the user after a
successful operation.

#### Takes arguments

The text can be multiline.

#### Usable in

* `install`
* `configure`
* `run`
