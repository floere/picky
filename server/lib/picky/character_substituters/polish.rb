# -*- coding: utf-8 -*-

module Picky

  module CharacterSubstituters

    class Polish

      def initialize
        @chars = ActiveSupport::Multibyte.proxy_class
      end

      def substitute text
        trans = @chars.new(text).normalize :kd

        trans.gsub! 'Ł', 'L'
        trans.gsub! 'ł', 'l'

        trans.unpack('U*').select { |cp|
          cp < 0x0300 || cp > 0x035F
        }.pack 'U*'
      end

      def to_s
        self.class.name
      end

    end

  end

end
