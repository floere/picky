module Sources
  
  # Raised when a CSV source is instantiated without a file.
  #
  # Example:
  #   Sources::CSV.new(:column1, :column2)
  #
  class NoCSVFileGiven < StandardError; end
  
  # Describes a CSV source, a file with csv in it.
  # Give it a sequence of category names and a file option with the filename.
  #
  class CSV < Base
    
    attr_reader :file_name, :csv_options, :category_names
    
    def initialize *category_names, options
      require 'csv'
      @category_names = category_names
      
      @csv_options    = Hash === options && options || {}
      @file_name      = @csv_options.delete(:file) || raise_no_file_given(category_names)
    end
    
    #
    #
    def raise_no_file_given category_names
      raise NoCSVFileGiven.new(category_names.join(', '))
    end
    
    # Harvests the data to index.
    #
    def harvest _, category
      index = category_names.index category.from
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
      ::CSV.foreach file_name, csv_options, &block
    end
    
  end
  
end