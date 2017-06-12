#!/usr/bin/env ruby

require("pathname")

class MalformedDotfileError < StandardError; end

module OS
  SYMBOLS = [:arch_linux, :macos]

  def self.parse(os_spec, context)
    os_spec = [os_spec] unless os_spec.is_a? Array
    os_spec.each do |os|
      raise MalformedDotfileError.new(
              "#{context}with_os argument '#{os}' is not a symbol"
            ) unless os.is_a? Symbol
      raise MalformedDotfileError.new(
              "#{context}unknown with_os argument '#{os}'"
            ) unless SYMBOLS.include? os
    end
    return os_spec
  end

  def self.matches(os_spec)
    return true # FIXME
  end
end

class Dotfile
  def initialize(filename)
    @filename = filename
    @runnables = {}
    @systems = []
    @context = "#{@filename}: "
    instance_eval(File.read(filename), filename)
  end

  private

  def target(name, &block)
    raise MalformedDotfileError.new(
            "#{@context}target name '#{name}' is not a string"
          ) unless name.is_a? String
    raise MalformedDotfileError.new(
            "#{@context}duplicate declaration of target '#{name}'"
          ) if @runnables.key? name
    @runnables[name] = Target.new(
      name, [], "#{@context}target #{name}: ", &block)
  end

  def task(name, &block)
    raise MalformedDotfileError.new(
            "#{@context}task name '#{name}' is not a string"
          ) unless name.is_a? String
    raise MalformedDotfileError.new(
            "#{@context}duplicate declaration of task '#{name}'"
          ) if @runnables.key? name
    @runnables[name] = Task.new(
      name, [], "#{@context}target #{name}: ", &block)
  end

  def with_os(os_spec, &block)
    RunnableOSWrapper.handle(@systems + [OS.parse(os_spec, @context)],
                             @runnables,
                             "#{@context}with_os #{os_spec}: ",
                             &block)
  end
end

class Runnable
  def initialize(name, systems, context, &block)
    @name = name
    @systems = systems
    @desc = nil
    @homepage = nil
    @min_version = nil
    @options = {}
    @runnables = {}
    @context = context
    instance_eval(&block)
  end

  private

  def desc(desc)
    raise MalformedDotfileError.new(
            "#{@context}more than one desc specified"
          ) unless @desc.nil?
    raise MalformedDotfileError.new(
            "#{@context}desc '#{desc}' is not a string"
          ) unless desc.is_a? String
    @desc = desc
  end

  def homepage(homepage)
    raise MalformedDotfileError.new(
            "#{@context}more than one homepage specified"
          ) unless @homepage.nil?
    raise MalformedDotfileError.new(
            "#{@context}homepage '#{homepage}' is not a string"
          ) unless homepage.is_a? String
    @homepage = homepage
  end

  def min_version(min_version)
    raise MalformedDotfileError.new(
            "#{@context}more than one min_version specified"
          ) unless @min_version.nil?
    raise MalformedDotfileError.new(
            "#{@context}min_version '#{min_version}' is not a string"
          ) unless min_version.is_a? String
    begin
      @min_version = Gem::Version.new(min_version)
    rescue ArgumentError
      raise MalformedDotfileError.new(
              "#{@context}malformed min_version '#{min_version}'"
            )
    end
  end

  def option(option)
    raise MalformedDotfileError.new(
            "#{@context}option '#{option}' is not a string"
          ) unless option.is_a? String
    # Option "windowed" is off by default; option "no-windowed" is
    # on by default. But we refer to both of them as "windowed"
    # internally.
    default_value = option.start_with? "no-"
    option.slice! "no-"
    raise MalformedDotfileError.new(
            "#{@context}option '#{option}' specified more than once"
          ) if @options.key? option
    @options[option] = default_value
  end

  def target(name, &block)
    raise MalformedDotfileError.new(
            "#{@context}target name '#{name}' is not a string"
          ) unless name.is_a? String
    raise MalformedDotfileError.new(
            "#{@context}duplicate declaration of target '#{name}'"
          ) if @runnables.key? name
    @runnables[name] = Target.new(
      name, @systems, "#{@context}target #{name}: ", &block)
  end

  def task(name, &block)
    raise MalformedDotfileError.new(
            "#{@context}task name '#{name}' is not a string"
          ) unless name.is_a? String
    raise MalformedDotfileError.new(
            "#{@context}duplicate declaration of task '#{name}'"
          ) if @runnables.key? name
    @runnables[name] = Task.new(
      name, @systems, "#{@context}target #{name}: ", &block)
  end

  def with_os(os_spec, &block)
    RunnableOSWrapper.handle(@systems + [OS.parse(os_spec, @context)],
                             @runnables,
                             "#{@context}with_os #{os_spec}: ",
                             &block)
  end
end

class Target < Runnable
  def initialize(name, systems, context, &block)
    @test = nil
    @install = nil
    @configure = nil
    super
    raise MalformedDotfileError.new(
            "#{@context}no install stanza provided"
          ) if @install.nil?
  end

  private

  def test(&block) # shadows Kernel::test
    raise MalformedDotfileError.new(
            "#{@context}test stanza specified more than once"
          ) unless @test.nil?
    @test = TestStanza.new(
      @options,
      "#{@context}test: ",
      &block)
  end

  def install(&block)
    raise MalformedDotfileError.new(
            "#{@context}install stanza specified more than once"
          ) unless @install.nil?
    @install = FullStanza.new(
      @options,
      "#{@context}install: ",
      &block)
  end

  def configure(&block)
    raise MalformedDotfileError.new(
            "#{@context}configure stanza specified more than once"
          ) unless @configure.nil?
    @configure = FullStanza.new(
      @options,
      "#{@context}configure: ",
      &block)
  end
end

class Task < Runnable
  def initialize(name, systems, context, &block)
    @run = nil
    super
    raise MalformedDotfileError.new(
            "#{@context}no run stanza provided"
          ) if @run.nil?
  end

  private

  def run(&block)
    raise MalformedDotfileError.new(
            "#{@context}run stanza specified more than once"
          ) unless @run.nil?
    @run = FullStanza.new(
      @options,
      "#{@context}run: ",
      &block)
  end
end

class RunnableOSWrapper
  def self.handle(systems, runnables, context, &block)
    @systems = systems
    @context = context
    @runnables = runnables
    instance_eval(&block)
  end

  private

  def self.target(name, &block)
    raise MalformedDotfileError.new(
            "#{@context}target name '#{name}' is not a string"
          ) unless name.is_a? String
    raise MalformedDotfileError.new(
            "#{@context}duplicate declaration of target '#{name}'"
          ) if @runnables.key? name
    @runnables[name] = Target.new(
      name, @systems, "#{@context}target #{name}: ", &block)
  end

  def self.task(name, &block)
    raise MalformedDotfileError.new(
            "#{@context}task name '#{name}' is not a string"
          ) unless name.is_a? String
    raise MalformedDotfileError.new(
            "#{@context}duplicate declaration of task '#{name}'"
          ) if @runnables.key? name
    @runnables[name] = Task.new(
      name, @systems, "#{@context}target #{name}: ", &block)
  end

  def self.with_os(os_spec, &block)
    RunnableOSWrapper.handle(@systems + [OS.parse(os_spec, @context)],
                             @runnables,
                             "#{@context}with_os #{os_spec}: ",
                             &block)
  end
end

module StanzaItemContainer
  def home
    return Dir.home
  end

  def dotfiles
    return (Pathname.new(__dir__) + "test/dotfiles").to_s # FIXME
  end

  def local
    return (Pathname.new(__dir__) + "test/local").to_s # FIXME
  end

  def binary(
        path,
        min_version: nil,
        subcommand: [],
        skip_prefix: //,
        returns_nonzero: false)
    raise MalformedDotfileError.new(
            "#{@context}binary used in non-test stanza"
          ) unless in_test_stanza?
    raise MalformedDotfileError.new(
            "#{@context}binary path '#{path}' is not a string"
          ) unless path.is_a? String
    raise MalformedDotfileError.new(
            "#{@context}binary min_version argument '#{min_version}' "\
            "is not a string"
          ) unless min_version.is_a? String or min_version.nil?
    begin
      unless min_version.nil?
        min_version = Gem::version.new(min_version)
      end
    rescue ArgumentError
      raise MalformedDotfileError.new(
              "#{@context}malformed binary min_version argument "\
              "'#{min_version}'"
            )
    end
    raise MalformedDotfileError.new(
            "#{@context}binary subcommand argument '#{subcommand}' "\
            "is not a string or array"
          ) unless subcommand.is_a? String or subcommand.is_a? Array
    if subcommand.is_a? String
      subcommand = [subcommand]
    end
    raise MalformedDotfileError.new(
            "#{@context}binary skip_prefix argument '#{skip_prefix}' "\
            "is not a regexp"
          ) unless skip_prefix.is_a? Regexp
    raise MalformedDotfileError.new(
            "#{@context}binary returns_nonzero argument "\
            "#{returns_nonzero} is not a boolean"
          ) unless [true, false].include? returns_nonzero
    @actions << BinaryStanzaItem.new(
      path,
      min_version,
      subcommand,
      skip_prefix,
      returns_nonzero,
      "#{@context}binary #{path}: ")
  end

  def dispatch(dispatch, iname, dname, dtypename, dtypes)
    # Key:
    #   iname = item name
    #   dname = dispatch name
    #   dtypename = dispatch type name
    #   dtype = dispatch type
    if in_test_stanza?
      raise MalformedDotfileError.new(
              "#{@context}#{iname} argument '#{dispatch}' in test "\
              "stanza is not a #{dtypename}"
            ) unless dtypes.any? { |dtype| dispatch.is_a? dtype }
      dispatch = {:check => dispatch}
    else
      raise MalformedDotfileError.new(
              "#{@context}#{iname} argument '#{dispatch}' is not "\
              "a hash or #{dtype}"
            ) unless dispatch.is_a? Hash or
        dtypes.any? { |dtype| dispatch.is_a? dtype }
      if dtypes.any? { |dtype| dispatch.is_a? dtype }
        dispatch = {:run => dispatch}
      end
    end
    dispatch.each do |type, item|
      raise MalformedDotfileError.new(
              "#{@context}#{iname} type '#{type}' is not a symbol"
            ) unless type.is_a? Symbol
      raise MalformedDotfileError.new(
              "#{@context}unknown #{iname} type '#{type}'"
            ) unless [:check, :run, :update, :unrun].include? type
      raise MalformedDotfileError.new(
              "#{@context}#{iname} #{dname} '#{item}' is not a #{dtypename}"
            ) unless dtypes.any? { |dtype| item.is_a? dtype }
      # Terrible hack for script only
      if item.is_a? String
        item = [item]
      end
    end
    raise MalformedDotfileError.new(
            "#{@context}#{iname} argument hash is missing :run entry"
          ) unless dispatch.include? :run or in_test_stanza?
    return dispatch
  end

  def block(arg=nil, &block)
    if block_given?
      raise MalformedDotfileError.new(
              "#{@context}both block and argument given to block"
            ) unless arg.nil?
      arg = Proc.new(&block)
    end
    @actions << BlockStanzaItem.new(
      dispatch(arg, "block", "block", "block", [Proc]),
      "#{@context}block: ")
  end

  def script(arg=nil)
    @actions << ScriptStanzaItem.new(
      dispatch(arg, "script", "path", "string or array", [String, Array]),
      "#{@context}script: "
    )
  end

  def depends_on(targets, configured=false)
    if configured
      method = "depends_on"
    else
      method = "depends_on_configured"
    end
    if targets.is_a? String
      targets = {targets => :required}
    end
    raise MalformedDotfileError.new(
            "#{@context}#{method} argument '#{targets}' "\
            "is not string or hash"
          ) unless targets.is_a? Hash
    targets.each do |target, type|
      raise MalformedDotfileError.new(
              "#{@context}unknown #{method} type '#{type}'"
            ) unless [:required, :recommended, :optional].include? type
      @actions << DependsOnStanzaItem.new(target, type, configured)
    end
  end

  def depends_on_configured(target)
    depends_on(target, true)
  end

  def temporarily_moving(path, &block)
    raise MalformedDotfileError.new(
            "#{@context}temporarily_moving argument '#{path}' "\
            "is not a string"
          ) unless path.is_a? String
    @actions << TemporarilyMovingWrapper.new(
      path,
      @options,
      self,
      "#{@context}temporarily_moving: ",
      &block)
  end

  def with_option(option, &block)
    raise MalformedDotfileError.new(
            "#{@context}with_option argument '#{option}' is not a string"
          ) unless option.is_a? String
    raise MalformedDotfileError.new(
            "#{@context}unknown option '#{option}'"
          ) unless @options.include? option
    @actions << OptionWrapper.new(
      option,
      true,
      @options,
      self,
      "#{@context}with_option #{option}: ",
      &block)
  end

  def without_option(option, &block)
    raise MalformedDotfileError.new(
            "#{@context}without_option argument '#{option}' is not a string"
          ) unless option.is_a? String
    raise MalformedDotfileError.new(
            "#{@context}unknown option '#{option}'"
          ) unless @options.include? option
    @actions << OptionWrapper.new(
      option,
      false,
      @options,
      self,
      "#{@context}without_option #{option}: ",
      &block)
  end

  def with_os(os_spec, &block)
    @actions << OSWrapper.new(
      OS.parse(os_spec, @context), @options,
      self,
      "#{@context}with_os #{os_spec}: ",
      &block)
  end

  def validate_package(package,
                       name,
                       flags: [],
                       min_version: nil,
                       tap: "homebrew/core")
    raise MalformedDotfileError.new(
            "#{@context}#{name} used in test stanza"
          ) if in_test_stanza?
    raise MalformedDotfileError.new(
            "#{@context}#{name} package '#{package}' is not a string"
          ) unless package.is_a? String
    raise MalformedDotfileError.new(
            "#{@context}#{name} flags argument '#{flags}' is not an array"
          ) unless flags.is_a? Array
    flags.each do |flag|
      raise MalformedDotfileError.new(
              "#{@context}#{name} flag '#{flag}' is not a string"
            ) unless flag.is_a? String
    end
    raise MalformedDotfileError.new(
            "#{@context}#{name} min_version argument '#{min_version}' "\
            "is not a string"
          ) unless min_version.is_a? String or min_version.nil?
    begin
      unless min_version.nil?
        min_version = Gem::Version.new(min_version)
      end
    rescue ArgumentError
      raise MalformedDotfileError.new(
              "#{@context}malformed #{name} min_version argument "\
              "'#{min_version}'"
            )
    end
    raise MalformedDotfileError.new(
            "#{@context}#{name} tap argument '#{tap}' is not a string"
          ) unless tap.is_a? String
  end

  def brew(package, flags: [], min_version: nil, tap: "homebrew/core")
    validate_package(
      package, "brew", flags: flags, min_version: min_version, tap: tap
    )
    @actions << BrewStanzaItem.new(
      package, flags, min_version, tap,
      "#{@context}brew #{package}: ")
  end

  def cask(package)
    validate_package(
      package, "cask"
    )
    @actions << CaskStanzaItem.new(package, "#{@context}cask #{package}: ")
  end

  def pacman(package, min_version: nil)
    validate_package(
      package, "pacman", min_version: min_version
    )
    @actions << PacmanStanzaItem.new(
      package, min_version, "#{@context}pacman #{package}: ")
  end

  def yaourt(package, min_version: nil)
    validate_package(
      package, "yaourt", min_version: min_version
    )
    @actions << YaourtStanzaItem.new(
      package, min_version, "#{@context}yaourt #{package}: ")
  end

  def remove(path)
    raise MalformedDotfileError.new(
            "#{@context}#{name} used in test stanza"
          ) if in_test_stanza?
    raise MalformedDotfileError.new(
            "#{@context}remove argument '#{path}' is not a string"
          ) unless path.is_a? String
    @actions << RemoveStanzaItem.new(path, "#{@context}remove #{path}: ")
  end

  def link(arg, name, target_dir, type)
    raise MalformedDotfileError.new(
            "#{@context}#{name} used in test stanza"
          ) if in_test_stanza?
    raise MalformedDotfileError.new(
            "#{@context}#{name} argument '#{arg}' is not a hash or string"
          ) unless arg.is_a? Hash or arg.is_a? String
    if arg.is_a? String
      arg = {arg => Pathname.new(arg).basename.to_s}
    end
    arg.each do |source, target|
      raise MalformedDotfileError.new(
              "#{@context}#{name} source '#{source}' is not a string"
            ) unless source.is_a? String
      raise MalformedDotfileError.new(
              "#{@context}#{name} target '#{target}' is not a string"
            ) unless target.is_a? String
      source, target = Pathname.new(source), Pathname.new(target)
      source = Pathname.new(dotfiles) + source unless source.absolute?
      target = Pathname.new(target_dir) + target unless target.absolute?
      @actions << type.new(
        source.to_s, target.to_s,
        "#{@context}#{name} #{target}: ")
    end
  end

  def symlink(arg)
    link(arg, "symlink", home, SymlinkStanzaItem)
  end

  def template(arg)
    link(arg, "template", local, TemplateStanzaItem)
  end

  def touch(path)
    raise MalformedDotfileError.new(
            "#{@context}touch used in test stanza"
          ) if in_test_stanza?
    raise MalformedDotfileError.new(
            "#{@context}touch argument '#{path}' is not a string"
          ) unless path.is_a? String
    @actions << TouchStanzaItem.new(path, "#{@context}touch #{path}: ")
  end

  def hints(hint)
    raise MalformedDotfileError.new(
            "#{@context}hints used in test stanza"
          ) if in_test_stanza?
    raise MalformedDotfileError.new(
            "#{@context}hints argument '#{path}' is not a string"
          ) unless hint.is_a? String
    @actions << HintsStanzaItem.new(hint, "#{@context}hints: ")
  end
end

# TODO: we can't keep track of anything at the top level of Stanza
# (even dependencies, unfortunately).

class Stanza
  def initialize(options, context, &block)
    @actions = []
    @options = options
    @context = context
    instance_eval(&block)
    remove_instance_variable :@options
  end

  include StanzaItemContainer
end

class TestStanza < Stanza
  def in_test_stanza?
    return true
  end
end

class FullStanza < Stanza
  def initialize(options, context, &block)
    super
  end

  def in_test_stanza?
    return false
  end
end

class StanzaItem
  def initialize(context)
    @context = context
  end
end

class BinaryStanzaItem < StanzaItem
  def initialize(path,
                 min_version,
                 subcommand,
                 skip_prefix,
                 returns_nonzero,
                 context)
    @path = path
    @min_version = min_version
    @subcommand = subcommand
    @skip_prefix = skip_prefix
    @returns_nonzero = returns_nonzero
    super context
  end
end

class DispatchingStanzaItem < StanzaItem
  def initialize(dispatch, context)
    @check = dispatch[:check]
    @run = dispatch[:run]
    @update = dispatch[:update]
    @unrun = dispatch[:unrun]
    super context
  end
end

class BlockStanzaItem < DispatchingStanzaItem
  def initialize(blocks, context)
    super
  end
end

class ScriptStanzaItem < DispatchingStanzaItem
  def initialize(scripts, context)
    super
  end
end

class DependsOnStanzaItem < StanzaItem
  def initialize(target, type, configured)
    @target = target
    @type = type
    @configured = configured
  end
end

class StanzaItemWrapper < StanzaItem
  def initialize(options, parent, context, &block)
    @actions = []
    @options = options
    @in_test_stanza = parent.in_test_stanza?
    instance_eval(&block)
    remove_instance_variable :@options
    super context
  end

  def in_test_stanza?
    return @in_test_stanza
  end

  include StanzaItemContainer
end

class TemporarilyMovingWrapper < StanzaItemWrapper
  def initialize(path, options, parent, context, &block)
    @path = path
    super options, parent, context, &block
  end
end

class OptionWrapper < StanzaItemWrapper
  def initialize(option, enabled, options, parent, context, &block)
    @option = option
    @enabled = enabled
    super options, parent, context, &block
  end
end

class OSWrapper < StanzaItemWrapper
  def initialize(os_spec, options, parent, context, &block)
    @os_spec = os_spec
    super options, parent, context, &block
  end
end

class BrewStanzaItem < StanzaItem
  def initialize(package, flags, min_version, tap, context)
    @package = package
    @flags = flags
    @min_version = min_version
    @tap = tap
    super context
  end
end

class CaskStanzaItem < StanzaItem
  def initialize(package, context)
    @package = package
    super context
  end
end

class PacmanStanzaItem < StanzaItem
  def initialize(package, min_version, context)
    @package = package
    @min_version = min_version
    super context
  end
end

class YaourtStanzaItem < StanzaItem
  def initialize(package, min_version, context)
    @package = package
    @min_version = min_version
    super context
  end
end

class RemoveStanzaItem < StanzaItem
  def initialize(path, context)
    @path = path
    super context
  end
end

class SymlinkStanzaItem < StanzaItem
  def initialize(source, target, context)
    @source = source
    @target = target
    super context
  end
end

class TemplateStanzaItem < StanzaItem
  def initialize(source, target, context)
    @source = target
    @target = target
    super context
  end
end

class TouchStanzaItem < StanzaItem
  def initialize(path, context)
    @path = path
    super context
  end
end

class HintsStanzaItem < StanzaItem
  def initialize(hints, context)
    @hints = hints
    super context
  end
end

Dotfile.new("test/Dotfile.rb") # FIXME
