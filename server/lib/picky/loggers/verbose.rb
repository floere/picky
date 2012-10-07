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
      
      # Puts a text in the form:
      #   12:34:56: text here
      #
      def timed_exclaim text
        io.puts "#{Time.now.strftime("%H:%M:%S")}: #{text}"
        flush
      end
      
    end
    
  end
  
end