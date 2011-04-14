module Index

  # An index that is persisted in files, loaded at startup and kept in memory at runtime.
  #
  class Memory < Base

    # Create a new memory index for indexing and for querying.
    #
    # Parameters:
    # * name: The identifier of the index. Used:
    #   - to identify an index (e.g. by you in Rake tasks: Indexes[:the_identifier]).
    #   - in the frontend to describe which index a result came from.
    #   - index directory naming (index/development/the_identifier/<lots of indexes>)
    # * source: The source the data comes from. See Sources::Base.
    #
    # Options:
    # * result_identifier: Use if you'd like a different identifier/name in the results JSON than the name of the index.
    #
    def initialize name, options = {}
      super name, options

      options[:indexing_bundle_class] ||= Internals::Indexing::Bundle::Memory
      options[:indexed_bundle_class]  ||= Internals::Indexed::Bundle::Memory
    end

  end

end