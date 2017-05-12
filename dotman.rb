#!/usr/bin/env ruby

class Runnable
end

class Target < Runnable
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

require_relative "./Dotfile"
