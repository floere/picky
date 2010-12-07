# A Picky Application is where you configure the whole search engine.
#
# Start by subclassing Application:
#   class MyGreatSearch < Application
#     # Your configuration goes here.
#   end
# The generator
#   $ picky project project_name
# will generate an example <tt>project_name/app/application.rb</tt> file for you
# with some example code inside.
#
# Next, define where your data comes from. You use the <tt>index</tt> method for that:
#   my_index = index :some_index_name, some_source
# You give the index a name (or identifier), and a source (see Sources), where its data comes from. Let's do that:
#   class MyGreatSearch < Application
#     
#     books = index :books, Sources::CSV.new(:title, :author, :isbn, file:'app/library.csv')
#     
#   end
# Now we have an index <tt>books</tt>.
# 
# That on itself won't do much good. Picky needs us to define categories on the data.
# 
# Categories help your user find data.
# It's best if you look at an example yourself: http://floere.github.com/picky/examples.html
#
# Let's go ahead and define a category:
#   class MyGreatSearch < Application
#     
#     books = index :books, Sources::CSV.new(:title, :author, :isbn, file:'app/library.csv')
#     books.define_category :title
#
#   end
# Now we could already run the indexer:
#   $ rake index
# Now we have indexed data, but nobody to ask the index anything.
#
# We need somebody who asks the index (a Query object). That works like this:
#    full_books_query = Query::Full.new books
# Full just means that the ids are returned with the results.
# Picky also offers a Query that returns live results, Query::Live. But that's not important right now.
# 
# Now we have somebody we can ask about the index. But no external interface.
# 
# Let's add a URL path to which we can send our queries. We do that with the route method:
#   route %r{\A/books/full\Z} => full_books_query
# In full glory:
#   class MyGreatSearch < Application
#     
#     books = index :books, Sources::CSV.new(:title, :author, :isbn, file:'app/library.csv')
#     books.define_category :title
#
#     full_books_query = Query::Full.new books
#
#     route %r{\Abooks/full\Z} => full_books_query
#
#   end
# That's it!
#
# Now run the indexer and server:
#   $ rake index
#   $ rake start
# Run your first query:
#   $ curl 'localhost:8080/books/full?query=hello server'
#
class Application
  
  class << self
    
    # API
    #
    
    # Returns a configured tokenizer that
    # is used for indexing by default.
    # 
    def default_indexing options = {}
      Tokenizers::Index.default = Tokenizers::Index.new(options)
    end
    
    # Returns a configured tokenizer that
    # is used for querying by default.
    # 
    def default_querying options = {}
      Tokenizers::Query.default = Tokenizers::Query.new(options)
    end
    
    # Create a new index for indexing and for querying.
    #
    # Parameters:
    # * name: The identifier of the index. Used:
    #   - to identify an index (e.g. by you in Rake tasks).
    #   - in the frontend to describe which index a result came from.
    #   - index directory naming (index/development/the_identifier/<lots of indexes>)
    # * source: The source the data comes from. See Sources::Base. # TODO Sources (all).
    #
    # Options:
    # * result_type: # TODO Rename.
    #
    def index name, source, options = {}
      IndexAPI.new name, source, options
    end
    
    # Routes.
    #
    delegate :route, :root, :to => :routing
    
    #
    # API
    
    
    # A Picky application implements the Rack interface.
    #
    # Delegates to its routing to handle a request.
    #
    def call env
      routing.call env
    end
    def routing # :nodoc:
      @routing ||= Routing.new
    end
    
    # Finalize the subclass as soon as it
    # has finished loading.
    #
    attr_reader :apps # :nodoc:
    def initialize_apps # :nodoc:
      @apps ||= []
    end
    def inherited app # :nodoc:
      initialize_apps
      apps << app
    end
    def finalize_apps # :nodoc:
      initialize_apps
      apps.each &:finalize
    end
    # Finalizes the routes.
    #
    def finalize # :nodoc:
      routing.freeze
    end
    
    # TODO Add more info if possible.
    #
    def to_s # :nodoc:
      "#{self.name}:\n#{routing}"
    end
    
  end
end