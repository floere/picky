# encoding: utf-8
#
# THINK Does it also remove diacritics, like べ to へ?
#
module Picky

  module CharacterSubstituters

    # Substitutes Umlauts like
    # ä, ö, ü => ae, oe, ue.
    # (and more, see specs)
    #
    class WestEuropean < Base

      # Substitutes occurrences of certain characters
      # (like Umlauts) with ASCII representations of them.
      #
      # Examples:
      #   ä -> ae
      #   Ö -> Oe
      #   ß -> ss
      #   ç -> c
      #
      # (See the associated spec for all examples)
      #
      def substitute text
        trans = @chars.new(text).normalize :kd

        # Substitute special cases.
        #
        trans.gsub! 'ß', 'ss'

        # Substitute umlauts (of A,O,U,a,o,u).
        #
        trans.gsub! /([AOUaou])\314\210/u, '\1e'

        # Get rid of ecutes, graves etc.
        #
        trans.unpack('U*').select { |cp|
          cp < 0x0300 || cp > 0x035F
        }.pack 'U*'
      end

    end

  end

end