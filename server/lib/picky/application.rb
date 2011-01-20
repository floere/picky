# = Picky Applications
#
# A Picky Application is where you configure the whole search engine.
#
# This is a step-by-step description on how to configure your Picky app.
#
# Start by subclassing Application:
#   class MyGreatSearch < Application
#     # Your configuration goes here.
#   end
# The generator
#   $ picky generate unicorn_server project_name
# will generate an example <tt>project_name/app/application.rb</tt> file for you
# with some example code inside.
#
# == index(name, source)
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
# That on itself won't do much good.
#
# == index.define_category(identifier, options = {})
#
# Picky needs us to define categories on the data.
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
#
# (You can define similarity or partial search capabilities on a category, see http://github.com/floere/picky/wiki/Categories-configuration for info)
#
# So now we have indexed data (the title), but nobody to ask the index anything.
#
# == Query::Full.new(*indexes, options = {})
#
# We need somebody who asks the index (a Query object, also see http://github.com/floere/picky/wiki/Queries-Configuration). That works like this:
#    full_books_query = Query::Full.new books
# Full just means that the ids are returned with the results.
# Picky also offers a Query that returns live results, Query::Live. But that's not important right now.
# 
# Now we have somebody we can ask about the index. But no external interface.
# 
# == route(/regexp1/ => query1, /regexp2/ => query2, ...)
#
# Let's add a URL path (a Route, see http://github.com/floere/picky/wiki/Routing-configuration) to which we can send our queries. We do that with the route method:
#   route %r{^/books/full$} => full_books_query
# In full glory:
#   class MyGreatSearch < Application
#     
#     books = index :books, Sources::CSV.new(:title, :author, :isbn, file:'app/library.csv')
#     books.define_category :title
#
#     full_books_query = Query::Full.new books
#
#     route %r{^/books/full$} => full_books_query
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
# Nice, right? Your first query!
#
# Maybe you don't find everything. We need to process the data before it goes into the index.
#
# == default_indexing(options = {})
#
# That's what the <tt>default_indexing</tt> method is for:
#   default_indexing options
# Read more about the options here: http://github.com/floere/picky/wiki/Indexing-configuration
#
# Same thing with the search text – we need to process that as well.
#
# == default_querying(options = {})
#
# Analog to the default_indexing method, we use the <tt>default_querying</tt> method.
#   default_querying options
# Read more about the options here: http://github.com/floere/picky/wiki/Querying-Configuration
#
# And that's all there is. It's incredibly powerful though, as you can combine, weigh, refine to the max.
#
# == Wiki
#
# Read more in the Wiki: http://github.com/floere/picky/wiki
#
# Have fun!
#
# == Full example
#
# Our example, fully fleshed out with indexing, querying, and weights:
#   class MyGreatSearch < Application
#     
#     default_indexing removes_characters: /[^a-zA-Z0-9\.]/,
#                      stopwords: /\b(and|or|in|on|is|has)\b/,
#                      splits_text_on: /\s/,
#                      removes_characters_after_splitting: /\./,
#                      substitutes_characters_with: CharacterSubstituters::WestEuropean.new,
#                      normalizes_words: [
#                        [/(.*)hausen/, 'hn'],
#                        [/\b(\w*)str(eet)?/, 'st']
#                      ]
#
#     default_querying removes_characters: /[^a-zA-Z0-9\s\/\-\,\&\"\~\*\:]/,
#                      stopwords: /\b(and|the|of|it|in|for)\b/,
#                      splits_text_on: /[\s\/\-\,\&]+/,
#                      removes_characters_after_splitting: /\./,
#                      substitutes_characters_with: CharacterSubstituters::WestEuropean.new,
#                      maximum_tokens: 4
#     
#     books = index :books, Sources::CSV.new(:title, :author, :isbn, file:'app/library.csv')
#     books.define_category :title,
#                           qualifiers: [:t, :title, :titre],
#                           partial:    Partial::Substring.new(:from => 1),
#                           similarity: Similarity::Phonetic.new(2)
#     books.define_category :author,
#                           partial: Partial::Substring.new(:from => -2)
#     books.define_category :isbn
#     
#     query_options = { :weights => { [:title, :author] => +3, [:author, :title] => -1 } }
#     
#     full_books_query = Query::Full.new books, query_options
#     live_books_query = Query::Full.new books, query_options
#     
#     route %r{^/books/full$} => full_books_query
#     route %r{^/books/live$} => live_books_query
#     
#   end
# That's actually already a full-blown Picky App!
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
    # * source: The source the data comes from. See Sources::Base.
    #
    # Options:
    # * result_identifier: Use if you'd like a different identifier/name in the results JSON than the name of the index. 
    #
    def index name, source, options = {}
      IndexAPI.new name, source, options
    end
    
    # Routes.
    #
    delegate :route, :root, :to => :rack_adapter
    
    #
    # API
    
    
    # A Picky application implements the Rack interface.
    #
    # Delegates to its routing to handle a request.
    #
    def call env
      rack_adapter.call env
    end
    def rack_adapter # :nodoc:
      @rack_adapter ||= FrontendAdapters::Rack.new
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
      check
      rack_adapter.finalize
    end
    # Checks app for missing things.
    #
    # Warns if something is missing.
    #
    # TODO Good specs.
    #
    def check # :nodoc:
      warnings = []
      warnings << check_external_interface
      puts "\n#{warnings.join(?\n)}\n\n" unless warnings.all? &:nil?
    end
    def check_external_interface
      "WARNING: No routes defined for application configuration in #{self.class}." if rack_adapter.empty?
    end
    
    # TODO Add more info if possible.
    #
    def to_s # :nodoc:
      "#{self.name}:\n#{rack_adapter}"
    end
    
  end
  
end