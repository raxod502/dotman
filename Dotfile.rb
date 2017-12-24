#!/usr/bin/env ruby

################################################################################
#### Zsh

target 'zsh' do
  desc 'Modern shell. Replaces bash.'
  homepage 'http://www.zsh.org/'
  min_version '5.2'

  test do
    binary 'zsh'
  end

  install do
    with_os :macos do
      brew 'zsh'
    end
    with_os :arch_linux do
      pacman 'zsh'
    end
  end

  configure do
    symlink '.zshrc'
    template 'templates/.zshrc.local'
    depends_on 'zplug' => :recommended
    depends_on 'git' => :optional
    depends_on 'exa' => :optional
  end

  task 'secure-compinit-directories' do
    desc 'Make zsh stop complaining about permissions on compinit files.'

    run do
      script :check => 'scripts/zsh/compinit-security/check.zsh',
             :run => 'scripts/zsh/compinit-security/run.zsh'
      depends_on 'zsh'
    end
  end

  task 'set-login-shell' do
    desc 'Set zsh as the login shell.'

    run do
      script :check => 'scripts/zsh/login-shell/check.zsh',
             :run => 'scripts/zsh/login-shell/run.zsh'
      depends_on 'zsh'
    end
  end
end

################################################################################
#### Tmux

with_os :macos do
  target 'reattach-to-user-namespace' do
    desc 'Wrapper program to fix clipboard access in Tmux on macOS.'
    homepage 'https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard'
    min_version '2.4'

    test do
      binary 'reattach-to-user-namespace'
    end

    install do
      brew 'reattach-to-user-namespace'
      hints <<~EOS
        The 'reattach-to-user-namespace' binary has been installed. It
        will be used automatically by Radian's Tmux configuration.
      EOS
    end
  end
end

target 'tmux' do
  desc 'Terminal multiplexer. Replacement for GNU screen.'
  homepage 'https://tmux.github.io/'
  min_version '2.2'

  test do
    binary 'tmux', subcommand: '-V'
  end

  install do
    with_os :macos do
      brew 'tmux'
    end
    with_os :arch_linux do
      pacman 'tmux'
    end
    hints <<~EOS
      The 'tmux' binary has been installed to /usr/local/bin. You can
      start a Tmux session by running 'tmux new-session -s <name>', or
      attach to an existing session with 'tmux attach'.
    EOS
  end

  configure do
    symlink ".tmux.conf"
    template "templates/.tmux.local.conf"
    symlink "#{local}/.tmux.local.conf"
    with_os :macos do
      depends_on 'reattach-to-user-namespace'
    end
  end
end

################################################################################
#### Git

target 'git' do
  desc 'The definitive distributed revision control system.'
  homepage 'https://git-scm.com/'
  min_version '2.12.2'

  test do
    binary 'git'
  end

  install do
    with_os :macos do
      brew 'git'
    end
    with_os :arch_linux do
      pacman 'git'
    end
  end

  configure do
    symlink ".gitconfig"
    template "templates/.gitconfig.local"
    symlink "#{local}/.gitconfig.local"
    symlink ".gitexclude"
  end
end

################################################################################
#### Emacs

target 'emacs' do
  desc 'Extensible, customizable, self-documenting text editor.'
  homepage 'https://www.gnu.org/software/emacs/'
  min_version '25.1'

  option 'windowed'

  test do
    binary 'emacs'
    binary 'emacsclient'
  end

  install do
    with_os :macos do
      with_option 'windowed' do
        cask 'emacs'
        symlink 'scripts/emacs/emacs' => 'usr/local/bin/emacs'
      end
      without_option 'windowed' do
        brew 'emacs'
      end
    end
    with_os :arch_linux do
      with_option 'windowed' do
        pacman 'emacs'
      end
      without_option 'windowed' do
        pacman 'emacs-nox'
      end
    end
    hints <<~EOS
      You can start Emacs by opening 'Emacs.app' from the Applications
      folder or by running the 'emacs' binary in /usr/local/bin. To run
      Emacs in the terminal, use 'emacs -nw'.

      You can use the Emacs client via the 'emacsclient' binary. Provide
      the '-nw' option to run in the terminal, and use
      '--alternate-editor=' to cause emacsclient to launch an Emacs
      server if one does not yet exist.
    EOS
  end

  configure do
    remove "#{home}/.emacs"
    remove "#{home}/.emacs.el"
    remove "#{home}/.emacs.elc"
    symlink "init.el" => "#{home}/.emacs.d/init.el"
    template "templates/init.local.el"
    symlink "#{local}/init.local.el" =>
            "#{home}/.emacs.d/init.local.el"
    symlink "radian-emacs" => "#{home}/.emacs.d/radian"
    symlink "versions.el" =>
            "#{home}/.emacs.d/straight/versions/radian.el"
    touch "versions.el"
    symlink "#{local}/versions.el" =>
            "#{home}/.emacs.d/straight/versions/radian-local.el"
    depends_on 'leiningen' => :optional
    depends_on 'cmake' => :optional
    depends_on 'libclang' => :optional
    depends_on 'fasd' => :optional
    depends_on 'ag' => :optional
    depends_on 'racket' => :optional
  end
end

################################################################################
#### Vim

target 'vim' do
  desc 'Ubiquitous, stable, highly efficient text editor.'
  homepage 'https://vim.sourceforge.io/'
  min_version '0.1.6'

  test do
    binary 'nvim'
  end

  install do
    with_os :macos do
      brew 'neovim', tap: 'neovim/neovim'
    end
    with_os :arch_linux do
      pacman 'neovim'
    end
    hints <<~EOS
      You can start Vim by running the 'nvim' binary in /usr/local/bin.
    EOS
  end

  configure do
    symlink 'init.vim' => '#{home}/.config/nvim/init.vim'
  end
end

################################################################################
#### Java

target 'java' do
  desc 'The Java programming language.'
  homepage 'https://www.java.com/'
  min_version '1.6'

  test do
    script ['/usr/libexec/java_home', '--failfast']
    binary 'javac', subcommand: '-version'
    binary 'java', subcommand: '-version'
  end

  install do
    with_os :macos do
      cask 'java'
    end
    with_os :arch_linux do
      pacman 'jdk8-openjdk'
    end
    hints <<~EOS
      You can compile, run, and package Java programs using the 'javac',
      'java', and 'jar' binaries installed in /usr/bin.
    EOS
  end
end

################################################################################
#### C++

target 'cmake' do
  desc 'Cross-platform C++ build manager.'
  homepage 'https://cmake.org/'
  min_version '3.7'

  test do
    binary 'cmake'
  end

  install do
    with_os :macos do
      brew 'cmake'
    end
    hints <<~EOS
      CMake has been installed as 'cmake' in /usr/local/bin.
    EOS
  end
end

target 'libclang' do
  desc 'C library for parsing C++ source code.'
  homepage 'https://clang.llvm.org/doxygen/group__CINDEX.html'
  min_version '3.9'

  install do
    with_os :macos do
      brew 'llvm'
    end
  end
end

################################################################################
#### Clojure

target 'leiningen' do
  desc 'Build manager for Clojure. Includes the Clojure language.'
  homepage 'https://leiningen.org/'
  min_version '2.7.1'

  test do
    temporarily_moving '#{home}/.lein/profiles.clj' do
      binary 'lein'
    end
  end

  install do
    with_os :macos do
      brew 'leiningen'
    end
    with_os :arch_linux do
      yaourt 'leiningen'
    end
    hints <<~EOS
      You can use Leiningen via the 'lein' binary. To start a REPL,
      run 'lein repl'.
    EOS
  end

  configure do
    symlink "profiles.clj" => "#{home}/.lein/profiles.clj"
  end
end

################################################################################
#### Racket

target 'racket' do
  desc 'The Racket programming language.'
  homepage 'https://racket-lang.org/'
  min_version '6.6'

  test do
    binary 'racket'
  end

  install do
    with_os :macos do
      cask 'racket'
    end
  end
end

################################################################################
#### Utilities

target 'ag' do
  desc 'A code searching tool similar to ack, but faster.'
  homepage 'https://github.com/ggreer/the_silver_searcher'
  min_version '0.33'

  test do
    binary 'ag'
  end

  install do
    with_os :macos do
      brew 'the_silver_searcher'
    end
  end
end

with_os :macos do
  target 'coreutils' do
    desc 'Basic shell utilities of the GNU operating system.'
    homepage 'https://www.gnu.org/software/coreutils/coreutils.html'
    min_version '8.27'

    install do
      with_os :macos do
        brew 'coreutils'
      end
    end
  end
end

target 'exa' do
  desc 'A modern replacement for ls.'
  homepage 'https://the.exa.website/'
  min_version '0.4.0'

  test do
    binary 'exa', returns_nonzero: true
  end

  install do
    with_os :macos do
      brew 'exa'
    end
  end
end

target 'fasd' do
  desc 'Utility to jump to frequently used files and directories.'
  homepage 'https://github.com/raxod502/fasd'
  min_version '1.0.2'

  test do
    binary 'fasd'
  end

  install do
    with_os :macos do
      brew 'fasd', tap: 'raxod502/radian'
    end
  end
end

target 'hub' do
  desc 'Git wrapper that adds Github integration.'
  homepage 'https://hub.github.com/'
  min_version '2.3'

  test do
    binary 'hub', skip_prefix: /git version .+/
  end

  install do
    with_os :macos do
      brew 'hub', flags: ['devel']
    end
  end
end

target 'wget' do
  desc 'GNU file downloader. More convenient than curl.'
  homepage 'https://www.gnu.org/software/wget/'
  min_version '1.18'

  test do
    binary 'wget'
  end

  install do
    with_os :macos do
      brew 'wget'
    end
  end
end
