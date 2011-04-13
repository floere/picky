module Sources

  # Raised when a CSV source is instantiated without a file.
  #
  # Example:
  #   Sources::CSV.new(:column1, :column2) # without file option
  #
  class NoCSVFileGiven < StandardError; end

  # Describes a CSV source, a file with comma separated values in it.
  #
  # The first column is implicitly assumed to be the id column.
  #
  # It takes the same options as the Ruby 1.9 CSV class.
  #
  # Examples:
  #  Sources::CSV.new(:title, :author, :isbn, file:'data/a_csv_file.csv')
  #  Sources::CSV.new(:title, :author, :isbn, file:'data/a_csv_file.csv', col_sep:';')
  #  Sources::CSV.new(:title, :author, :isbn, file:'data/a_csv_file.csv', row_sep:"\n")
  #
  class CSV < Base

    # The CSV file's path, relative to PICKY_ROOT.
    #
    attr_reader :file_name

    # The options that were passed into #new.
    #
    attr_reader :csv_options, :key_format

    # The data category names.
    #
    attr_reader :category_names

    def initialize *category_names, options
      require 'csv'
      @category_names = category_names

      @csv_options = Hash === options && options || {}
      @file_name   = @csv_options.delete(:file) || raise_no_file_given(category_names)

      key_format   = options.delete :key_format
      @key_format  = key_format && key_format.to_sym || :to_i
    end

    def to_s
      parameters = category_names
      parameters << { file: file_name }
      parameters << csv_options unless csv_options.empty?
      %Q{#{self.class.name}(#{parameters.join(', ')})}
    end

    # Raises a NoCSVFileGiven exception.
    #
    def raise_no_file_given category_names # :nodoc:
      raise NoCSVFileGiven.new(category_names.join(', '))
    end

    # Harvests the data to index.
    #
    def harvest category
      index = category_names.index category.from
      get_data do |ary|
        indexed_id = ary.shift
        text       = ary[index]
        next unless text
        text.force_encoding 'utf-8' # TODO Still needed?
        yield indexed_id, text
      end
    end

    #
    #
    def get_data &block # :nodoc:
      ::CSV.foreach file_name, csv_options, &block
    end

  end

end