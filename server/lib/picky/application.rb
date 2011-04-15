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
# == Index::Memory.new(name)
#
# Next, define where your data comes from. You use the <tt>Index::Memory.new</tt> method for that:
#   my_index = Index::Memory.new :some_index_name
# You give the index a name (or identifier), and a source (see Sources), where its data comes from. Let's do that:
#   class MyGreatSearch < Application
#
#     books = Index::Memory.new :books do
#       source Sources::CSV.new(:title, :author, :isbn, file:'app/library.csv')
#     end
#
#   end
# Now we have an index <tt>books</tt>.
#
# That on itself won't do much good.
#
# Note that a Redis index is also available: Index::Redis.new.
#
# == category(identifier, options = {})
#
# Picky needs us to define categories on the data.
#
# Categories help your user find data.
# It's best if you look at an example yourself: http://floere.github.com/picky/examples.html
#
# Let's go ahead and define a category:
#   class MyGreatSearch < Application
#
#     books = Index::Memory.new :books do
#       source   Sources::CSV.new(:title, :author, :isbn, file:'app/library.csv')
#       category :title
#     end
#
#   end
# Now we could already run the indexer:
#   $ rake index
#
# (You can define similarity or partial search capabilities on a category, see http://github.com/floere/picky/wiki/Categories-configuration for info)
#
# So now we have indexed data (the title), but nobody to ask the index anything.
#
# == Search.new(*indexes, options = {})
#
# We need somebody who asks the index (a Query object, also see http://github.com/floere/picky/wiki/Queries-Configuration):
#    books_search = Search.new books
#
# Now we have somebody we can ask about the index. But no external interface.
#
# == route(/regexp1/ => search1, /regexp2/ => search2, ...)
#
# Let's add a URL path (a Route, see http://github.com/floere/picky/wiki/Routing-configuration) to which we can send our queries. We do that with the route method:
#   route %r{^/books$} => books_query
# In full glory:
#   class MyGreatSearch < Application
#
#     books = index :books do
#       source   Sources::CSV.new(:title, :author, :isbn, file:'app/library.csv')
#       category :title
#     end
#
#     route %r{^/books$} => Search.new(books)
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
# == indexing(options = {})
#
# That's what the <tt>indexing</tt> method is for:
#   indexing options
# Read more about the options here: http://github.com/floere/picky/wiki/Indexing-configuration
#
# Same thing with the search text – we need to process that as well.
#
# == searching(options = {})
#
# Analog to the indexing method, we use the <tt>searching</tt> method.
#   searching options
# Read more about the options here: http://github.com/floere/picky/wiki/Searching-Configuration
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
#     indexing removes_characters: /[^a-zA-Z0-9\.]/,
#              stopwords: /\b(and|or|in|on|is|has)\b/,
#              splits_text_on: /\s/,
#              removes_characters_after_splitting: /\./,
#              substitutes_characters_with: CharacterSubstituters::WestEuropean.new,
#              normalizes_words: [
#                [/(.*)hausen/, 'hn'],
#                [/\b(\w*)str(eet)?/, 'st']
#              ]
#
#     searching removes_characters: /[^a-zA-Z0-9\s\/\-\,\&\"\~\*\:]/,
#               stopwords: /\b(and|the|of|it|in|for)\b/,
#               splits_text_on: /[\s\/\-\,\&]+/,
#               removes_characters_after_splitting: /\./,
#               substitutes_characters_with: CharacterSubstituters::WestEuropean.new,
#               maximum_tokens: 4
#
#     books = Index::Memory.new :books do
#       source   Sources::CSV.new(:title, :author, :isbn, file:'app/library.csv')
#       category :title,
#                qualifiers: [:t, :title, :titre],
#                partial:    Partial::Substring.new(:from => 1),
#                similarity: Similarity::DoubleMetaphone.new(2)
#       category :author,
#                partial: Partial::Substring.new(:from => -2)
#       category :isbn
#     end
#
#     route %r{^/books$} => Search.new(books) do
#       boost [:title, :author] => +3, [:author, :title] => -1
#     end
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
    def indexing options = {}
      Internals::Tokenizers::Index.default = Internals::Tokenizers::Index.new(options)
    end
    alias default_indexing indexing

    # Returns a configured tokenizer that
    # is used for querying by default.
    #
    def searching options = {}
      Internals::Tokenizers::Query.default = Internals::Tokenizers::Query.new(options)
    end
    alias default_querying searching
    alias querying searching

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
      @rack_adapter ||= Internals::FrontendAdapters::Rack.new
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
    def check # :nodoc:
      warnings = []
      warnings << check_external_interface
      warn "\n#{warnings.join(?\n)}\n\n" unless warnings.all? &:nil?
    end
    def check_external_interface
      "WARNING: No routes defined for application configuration in #{self.class}." if rack_adapter.empty?
    end

    def to_s # :nodoc:
      <<-APPLICATION
\033[1m#{name}\033[m
#{to_stats.indented_to_s}
APPLICATION
    end
    def to_stats
      <<-APP
\033[1mIndexing (default)\033[m:
#{Internals::Tokenizers::Index.default.indented_to_s}

\033[1mQuerying (default)\033[m:
#{Internals::Tokenizers::Query.default.indented_to_s}

\033[1mIndexes\033[m:
#{Indexes.to_s.indented_to_s}

\033[1mRoutes\033[m:
#{to_routes.indented_to_s}
APP
    end
    def to_routes
      rack_adapter.to_s
    end

  end

end