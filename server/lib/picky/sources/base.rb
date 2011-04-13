# = Data Sources
#
# Currently, Picky offers the following Sources:
# * CSV (comma – or other – separated file)
# * Couch (CouchDB, key-value store)
# * DB (Databases, foremost MySQL)
# * Delicious (http://del.icio.us, online bookmarking service)
# See also:
# http://github.com/floere/picky/wiki/Sources-Configuration
#
# Don't worry if your source isn't here. Adding your own is easy:
# http://github.com/floere/picky/wiki/Contributing-sources
#
module Sources

  # Sources are where your data comes from.
  #
  # A source has 1 mandatory and 2 optional methods:
  # * connect_backend (_optional_): called once for each type/category pair.
  # * harvest: Used by the indexer to gather data. Yields an indexed_id (string or integer) and a string value.
  # * take_snapshot (_optional_): called once for each type.
  #
  # This base class "implements" all these methods, but they don't do anything.
  # Subclass this class <tt>class MySource < Base</tt> and override the methods in your source to do something.
  #
  class Base

    attr_reader :key_format

    # Connect to the backend.
    #
    # Called once per index/category combination before harvesting.
    #
    # Examples:
    # * The DB backend connects the DB adapter.
    # * We open a connection to a key value store.
    # * We open an file with data.
    #
    def connect_backend

    end

    # Called by the indexer when gathering data.
    #
    # Yields the data (id, text for id) for the given category.
    #
    # When implementing or overriding your own,
    # be sure to <tt>yield(id, text_for_id)</tt> (or <tt>block.call(id, text_for_id)</tt>)
    # for the given type symbol and category symbol.
    #
    # Note: Since harvest needs to be implemented, it has no default impementation.
    #
    # def harvest category # :yields: id, text_for_id
    #
    # end

    # Used to take a snapshot of your data if it is fast changing.
    #
    # Called once for each type before harvesting.
    #
    # Example:
    # * In a DB source, a table based on the source's select statement is created.
    #
    def take_snapshot index

    end

  end

end