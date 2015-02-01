module Picky

  module Backends

    # Naive implementation of a file-based index.
    # In-Memory Hash with length, offset:
    #   { :bla => [20, 312] }
    # That map to positions the File, encoded in JSON:
    #   ...[1,2,3,21,7,4,13,15]...
    #
    class File < Backend
      
      def create_weights bundle, _ = nil
        Memory::JSON.new bundle.index_path(:weights)
      end
      
      def create_similarity bundle, _ = nil
        json bundle.index_path(:similarity)
      end

    end

  end

end