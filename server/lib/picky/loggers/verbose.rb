module Picky
  
  module Loggers
    
    # The verbose logger outputs all information.
    #
    class Verbose < Silent
      
      def info text
        timed_exclaim text
      end
      
      def tokenize index_or_category, prepared_file
        timed_exclaim %Q{  "#{index_or_category.identifier}": Tokenized -> #{prepared_file.path.gsub("#{Picky.root}/", '')}.}
      end
      
      def dump category
        timed_exclaim %Q{  "#{category.identifier}": Dumped -> #{category.index_directory.gsub("#{Picky.root}/", '')}/#{category.name}_*.}
      end
      
      def load category
        timed_exclaim %Q{  "#{category.identifier}": Loading index from cache.}
      end
      
      def adapt_for_logger
        super
        def timed_exclaim text
          output.info "#{Time.now.strftime("%H:%M:%S")}: #{text}"
        end
        def warn text
          output.warn text
        end
        def write message
          output << message
        end
      end
      def adapt_for_io
        super
        def timed_exclaim text
          output.puts "#{Time.now.strftime("%H:%M:%S")}: #{text}"
          flush
        end
        def warn text
          output.puts text
          flush
        end
        def write message
          output.write message
        end
      end
      
    end
    
  end
  
end