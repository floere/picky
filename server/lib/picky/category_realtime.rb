module Picky

  # TODO
  #
  class Category

    # TODO
    #
    def remove id
      indexed_exact.remove id
      indexed_partial.remove id
    end

    # TODO
    #
    def add id, tokens
      tokens.each do |text|
        next unless text
        text = text.to_sym
        indexed_exact.add id, text
      end
    end

  end

end