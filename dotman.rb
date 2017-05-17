#!/usr/bin/env ruby

class MalformedDotfileError < StandardError; end

module OS
  SYMBOLS = [:arch_linux, :macos]

  def self.parse(os_spec, context)
    os_spec = [os_spec] unless os_spec.is_a? Array
    os_spec.each do |os|
      raise MalformedDotfileError(
              "#{context}with_os argument '#{os}' is not a symbol"
            ) unless os.is_a? Symbol
      raise MalformedDotfileError(
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
    instance_eval File.read(filename)
  end

  private

  def target(name, &block)
    raise MalformedDotfileError(
            "#{@context}target name '#{name}' is not a string"
          ) unless name.is_a? String
    raise MalformedDotfileError(
            "#{@context}duplicate declaration of target '#{name}'"
          ) if @runnables.key? name
    @runnables[name] = Target.new(
      name, [], "#{@context}target #{name}: ", &block)
  end

  def task(name, &block)
    raise MalformedDotfileError(
            "#{@context}task name '#{name}' is not a string"
          ) unless name.is_a? String
    raise MalformedDotfileError(
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
  def initialize(context, &block)
    @runnables = {}
    @context = context
    instance_eval &block
  end
end

class StandardRunnable < Runnable
  def initialize(name, systems, context, &block)
    @name = name
    @systems = systems
    @desc = nil
    @homepage = nil
    @min_version = nil
    @options = {}
    super context, &block
  end

  private

  def desc(desc)
    raise MalformedDotfileError(
            "#{@context}more than one desc specified"
          ) unless @desc.nil?
    raise MalformedDotfileError(
            "#{@context}desc '#{desc}' is not a string"
          ) unless desc.is_a? String
    @desc = desc
  end

  def homepage(homepage)
    raise MalformedDotfileError(
            "#{@context}more than one homepage specified"
          ) unless @homepage.nil?
    raise MalformedDotfileError(
            "#{@context}homepage '#{homepage}' is not a string"
          ) unless homepage.is_a? String
    @homepage = homepage
  end

  def min_version(min_version)
    raise MalformedDotfileError(
            "#{@context}more than one min_version specified"
          ) unless @min_version.nil?
    raise MalformedDotfileError(
            "#{@context}min_version '#{min_version}' is not a string"
          ) unless min_version.is_a? String
    begin
      @min_version = Gem::Version.new(min_version)
    rescue ArgumentError
      raise MalformedDotfileError("#{@context}malformed min_version '#{min_version}'")
    end
  end

  def option(option)
    raise MalformedDotfileError(
            "#{@context}option '#{option}' is not a string"
          ) unless option.is_a? String
    # Option "windowed" is off by default; option "no-windowed" is
    # on by default. But we refer to both of them as "windowed"
    # internally.
    default_value = option.start_with? "no-"
    option.slice! "no-"
    raise MalformedDotfileError(
            "#{@context}option '#{option}' specified more than once"
          ) if @options.key? option
    @options[option] = default_value
  end

  def target(name, &block)
    raise MalformedDotfileError(
            "#{@context}target name '#{name}' is not a string"
          ) unless name.is_a? String
    raise MalformedDotfileError(
            "#{@context}duplicate declaration of target '#{name}'"
          ) if @runnables.key? name
    @runnables[name] = Target.new(
      name, @systems, "#{@context}target #{name}: ", &block)
  end

  def task(name, &block)
    raise MalformedDotfileError(
            "#{@context}task name '#{name}' is not a string"
          ) unless name.is_a? String
    raise MalformedDotfileError(
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

class Target < StandardRunnable
  def initialize(name, systems, context, &block)
    @test = nil
    @install = nil
    @configure = nil
    super
    raise MalformedDotfileError(
            "#{@context}no install stanza provided"
          ) if @install.nil?
  end

  private

  def test(&block) # shadows Kernel::test
    @test = TestStanza.new(&block)
  end

  def install(&block)
    @install = FullStanza.new(&block)
  end

  def configure(&block)
    @configure = FullStanza.new(&block)
  end
end

class Task < StandardRunnable
  def initialize(name, systems, context, &block)
    @run = nil
    super
    raise MalformedDotfileError(
            "#{@context}no run stanza provided"
          ) if @run.nil?
  end

  private

  def run(&block)
    @run = FullStanza.new(&block)
  end
end

class RunnableOSWrapper
  def self.handle(systems, runnables, context, &block)
    @systems = systems
    @context = context
    @runnables = runnables
  end

  private

  def target(name, &block)
    raise MalformedDotfileError(
            "#{@context}target name '#{name}' is not a string"
          ) unless name.is_a? String
    raise MalformedDotfileError(
            "#{@context}duplicate declaration of target '#{name}'"
          ) if @runnables.key? name
    @runnables[name] = Target.new(
      name, @systems, "#{@context}target #{name}: ", &block)
  end

  def task(name, &block)
    raise MalformedDotfileError(
            "#{@context}task name '#{name}' is not a string"
          ) unless name.is_a? String
    raise MalformedDotfileError(
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

class Stanza
end

class TestStanza < Stanza
end

class FullStanza < Stanza
end

class StanzaItem
end

class BinaryStanzaItem < StanzaItem
end

class BlockStanzaItem < StanzaItem
end

class ScriptStanzaItem < StanzaItem
end

class Dependency
end

class StanzaItemWrapper < StanzaItem
end

class TemporarilyMovingWrapper < StanzaItemWrapper
end

class OptionWrapper < StanzaItemWrapper
end

class OSWrapper < StanzaItemWrapper
end

class BrewItem < StanzaItem
end

class CaskItem < StanzaItem
end

class PacmanItem < StanzaItem
end

class YaourtItem < StanzaItem
end

class RemoveItem < StanzaItem
end

class SymlinkItem < StanzaItem
end

class TemplateItem < StanzaItem
end

dotfile = Dotfile.new("Dotfile.rb")
