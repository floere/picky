begin
  require 'google_hash'

  class ::GoogleHashSparseRubyToRuby
    alias each_pair each

    # This is mainly used in tests, which is
    # why we allow for a silly implementation.
    #
    def ==(other)
      return false unless other.respond_to?(:to_h)

      self.each do |key, value|
        return false if other[key] != value
      end
      other.each do |key, value|
        return false if self[key] != value
      end

      true
    end

    # I am a hashy thing.
    #
    def to_hash
      true
    end

    # TODO
    #
    def inject(init, &block)
      result = init
      each do |key, value|
        result = block.call result, [key, value]
      end
      result
    end

    # TODO
    #
    def size
      result = 0
      # each only accepts a block
      each { result += 1 }
      result
    end
  end
rescue LoadError
  # Welp. Don't do anything.
end
