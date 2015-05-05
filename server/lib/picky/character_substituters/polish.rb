# -*- coding: utf-8 -*-

module Picky

  module CharacterSubstituters

    class Polish < Base

      def substitute text
        trans = @chars.new(text).normalize :kd

        trans.gsub! 'Ł', 'L'
        trans.gsub! 'ł', 'l'

        trans.unpack('U*').select { |cp|
          cp < 0x0300 || cp > 0x035F
        }.pack 'U*'
      end

    end

  end

end
