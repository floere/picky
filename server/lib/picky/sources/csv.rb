module Sources
  
  # Describes a CSV source, a file with csv in it.
  # Give it a sequence of category names and a file option with the filename.
  #
  class NoCSVFileGiven < StandardError; end
  
  class CSV < Base
    
    attr_reader :file_name, :category_names
    
    def initialize *category_names, options
      require 'csv'
      @category_names = category_names
      @file_name   = Hash === options && options[:file] || raise_no_file_given(category_names)
    end
    
    #
    #
    def raise_no_file_given category_names
      raise NoCSVFileGiven.new(category_names.join(', '))
    end
    
    # Harvests the data to index.
    #
    def harvest _, category
      index = category_names.index category.name
      get_data do |ary|
        indexed_id = ary.shift.to_i # TODO is to_i necessary?
        text       = ary[index]
        next unless text
        text.force_encoding 'utf-8' # TODO Still needed?
        yield indexed_id, text
      end
    end
    
    #
    #
    def get_data &block
      ::CSV.foreach file_name, &block
    end
    
  end
  
end