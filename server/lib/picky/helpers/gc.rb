module Helpers
  module GC
    def gc_disabled &block
      ::GC.disable
      block.call
      ::GC.enable
      ::GC.start
    end
    alias disabled gc_disabled
  end
end