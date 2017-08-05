class CLITask
end

class HelpCLITask
  def initialize(subcommand)
    @subcommand = subcommand
  end
end

class VersionCLITask
end

class RegisterCLITask
  def initialize(name, path, select)
    @name = name
    @path = path
    @select = select
  end
end

class DeregisterCLITask
  def initialize(name)
    @name = name
  end
end

class RenameCLITask
  def initialize(old_name, new_name)
    @old_name = old_name
    @new_name = new_name
  end
end

class SelectionCLITask
  def initialize(name)
    @name = name
  end
end

class SelectCLITask < SelectionCLITask
end

class DeselectCLITask < SelectionCLITask
end

class LocalSetCLITask
  def initialize(name, path)
    @name = name
    @path = path
  end
end

class LocalUnsetCLITask
  def initialize(name)
    @name = name
  end
end

class InfoCLITask
  def initialize(name)
    @name = name
  end
end

module CLI
  @usage = <<~EOS
    dotman: one package manager to rule them all.

    Usage:
        dotman [SUBCOMMAND] [ARG...]

    Subcommands for general usage:
        help          show this message, or describe a subcommand
        version       show the version

    Subcommands for repository registration:
        register      tell dotman about a dotfiles repository
        deregister    make dotman forget a dotfiles repository
        rename        change the name of a dotfiles repository
        select        mark a dotfiles repository as currently active
        deselect      mark no dotfiles repository as currently active
        set-local     tell dotman about a local dotfiles repository
        unset-local   make dotman forget a local dotfiles repository

    Subcommands for package management:
        install       install software using the package manager
        uninstall     remove software using the package manager
        reinstall     uninstall and install combined
        configure     link dotfiles and perform software configuration
        unconfigure   unlink dotfiles and undo software configuration
        reconfigure   unconfigure and configure combined
        update        update software using the package manager
        run           run a user-defined task

    Subcommands for system maintenance:
        mv            move a file or directory and update symlinks
        git           perform git operations, detecting configuration changes
        local-git     perform git operations on the local dotfiles repository
  EOS

  def self.handle(args)
    case ARGV[0]
    when nil
      puts @usage
      exit 2
    end
  end
end
