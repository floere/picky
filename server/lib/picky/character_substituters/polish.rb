module Picky
  module CharacterSubstituters
    class Polish < Base
      def substitute(text)
        trans = @chars.new(text).unicode_normalize :nfkd

        trans.gsub! 'Ł', 'L'
        trans.gsub! 'ł', 'l'

        trans.unpack('U*').select do |cp|
          cp < 0x0300 || cp > 0x035F
        end.pack 'U*'
      end
    end
  end
end
