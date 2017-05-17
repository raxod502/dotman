#!/usr/bin/env ruby

class MalformedDotfileError < StandardError; end

module OS
  TYPES = [:arch_linux, :macos]

  def matches(os)
    return os == :macos # FIXME: make this check the OS
  end
end

class Dotfile
  def initialize(filename)
    @filename = filename
    @runnables = []
    instance_eval File.read(filename)
  end

  private

  def target(name, &block)
    # FIXME: check for duplicate targets
    @runnables << Target.new(name, "#{@filename}: target #{name}: ", &block)
  end

  def task(name, &block)
    # FIXME: check for duplicates
    @runnables << Task.new(name, "#{@filename}: task #{name}: ", &block)
  end

  def with_os(os, &block)
    # FIXME: check for duplicates?
    @runnables << OSWrapperRunnable.new(
      os, "#{@filename}: with_os #{os}: ", &block)
  end
end

class Runnable
  def initialize(diagnostic_context, &block)
    @runnables = []
    @diagnostic_context = diagnostic_context
    instance_eval &block
  end
end

class StandardRunnable < Runnable
  def initialize(name, diagnostic_context, &block)
    @name = name
    @desc = nil
    @homepage = nil
    @min_version = nil
    @options = {}
    super
  end

  private

  def desc(desc)
    if @desc.nil?
      if desc.is_a? String
        @desc = desc
      else
        raise MalformedDotfileError(@diagnostic_context +
                                    "desc '#{desc}' is not a string")
      end
    else
      raise MalformedDotfileError(@diagnostic_context +
                                  "more than one desc specified")
    end
  end

  def homepage(homepage)
    if @homepage.nil?
      if homepage.is_a? String
        @homepage = homepage
      else
        raise MalformedDotfileError(@diagnostic_context +
                                    "homepage '#{homepage}' is not a string")
      end
    else
      raise MalformedDotfileError(@diagnostic_context +
                                  "more than one homepage specified")
    end
  end

  def min_version(min_version)
    if @min_version.nil?
      if min_version.is_a? String
        begin
          @min_version = Gem::Version.new(min_version)
        rescue ArgumentError
          raise MalformedDotfileError(@diagnostic_context +
                                      "malformed min_version '#{min_version}'")
        end
      else
        raise MalformedDotfileError(@diagnostic_context +
                                    "min_version '#{min_version}' " +
                                    "is not a string")
      end
    else
      raise MalformedDotfileError(@diagnostic_context +
                                  "more than one min_version specified")
    end
  end

  def option(option)
    if option.is_a? String
      # Option "windowed" is off by default; option "no-windowed" is
      # on by default. But we refer to both of them as "windowed"
      # internally.
      default_value = option.start_with? "no-"
      option.slice! "no-"
      if @options.key? option
        raise MalformedDotfileError(@diagnostic_context +
                                    "option '#{option}' specified " +
                                    "more than once")
      else
        options[option] = default_value
      end
    else
      raise MalformedDotfileError(@diagnostic_context +
                                  "option '#{option}' is not a string")
    end
  end

  def target(name, &block)
    Target.new(name, @diagnostic_context + "target #{name}: ", &block)
  end

  def task(name, &block)
    Task.new(name, @diagnostic_context + "task #{name}: ", &block)
  end
end

class Target < StandardRunnable
  def initialize(name, diagnostic_context, &block)
    @test = nil
    @install = nil
    @configure = nil
    super
    if @install.nil?
      raise MalformedDotfileError(@diagnostic_context +
                                  "no install stanza provided")
    end
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
  def initialize(name, diagnostic_context, &block)
    @run = nil
    super
    if @run.nil?
      raise MalformedDotfileError(@diagnostic_context +
                                  "no run stanza provided")
    end
  end

  private

  def run(&block)
    @run = FullStanza.new(&block)
  end
end

# FIXME: operate on the runnable list directly, to avoid the need for
# this class
class OSWrapperRunnable < Runnable
  def initialize(os, diagnostic_context, &block)
    if os.is_a? Symbol
      if OS::TYPES.include? os
        @os = os
      else
        raise MalformedDotfileError(@diagnostic_context +
                                    "unknown with_os type '#{os}'")
      end
    else
      raise MalformedDotfileError(@diagnostic_context +
                                  "with_os argument '#{os}' not a symbol")
    end
  end

  private

  def target(name, &block)
    Target.new(name, @diagnostic_context + "target #{name}: ", &block)
  end

  def task(name, &block)
    Task.new(name, @diagnostic_context + "task #{name}: ", &block)
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
