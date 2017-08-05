#!/usr/bin/env ruby

require "./dsl"

module Paths
  @dotfiles = nil
  @local = nil
end

CLI.handle(ARGV)
