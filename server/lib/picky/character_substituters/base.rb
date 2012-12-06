# -*- coding: utf-8 -*-

module Picky

  module CharacterSubstituters

    class Base

      def initialize
        @chars = ActiveSupport::Multibyte.proxy_class
      end

      def to_s
        self.class.name
      end

    end

  end

end
