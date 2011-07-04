module Internals

  module Index

    class Files < Backend

      def initialize bundle_name, category
        super bundle_name, category

        # Note: We marshal the similarity, as the
        #       Yajl json lib cannot load symbolized
        #       values, just keys.
        #
        @index         = File::JSON.new    category.index_path(bundle_name, :index)
        @weights       = File::JSON.new    category.index_path(bundle_name, :weights)
        @similarity    = File::Marshal.new category.index_path(bundle_name, :similarity)
        @configuration = File::JSON.new    category.index_path(bundle_name, :configuration)
      end

      def to_s
        <<-FILES
Files:
#{"Index:      #{@index}".indented_to_s}
#{"Weights:    #{@weights}".indented_to_s}
#{"Similarity: #{@similarity}".indented_to_s}
#{"Config:     #{@configuration}".indented_to_s}
FILES
      end

    end

  end

end