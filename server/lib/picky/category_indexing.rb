#
#
class Category

  attr_reader :indexing_exact,
              :indexing_partial

  # Prepares and caches this category.
  #
  # This one should be used by users.
  #
  def index
    prepare
    cache
  end

  # Indexes, creates the "prepared_..." file.
  #
  def prepare
    with_data_snapshot do
      indexer.index [self]
    end
  end

  # Take a data snapshot if the source offers it.
  #
  def with_data_snapshot
    if source.respond_to? :with_snapshot
      source.with_snapshot(@index) do
        yield
      end
    else
      yield
    end
  end

  # Generates all caches for this category.
  #
  def cache
    generate_caches_from_source
    generate_partial
    generate_caches_from_memory
    dump_caches
    timed_exclaim %Q{"#{identifier}": Caching finished.}
  end
  # Generate the cache data.
  #
  def generate_caches_from_source
    indexing_exact.generate_caches_from_source
  end
  def generate_partial
    indexing_partial.generate_partial_from indexing_exact.inverted
  end
  def generate_caches_from_memory
    indexing_partial.generate_caches_from_memory
  end
  def dump_caches
    indexing_exact.dump
    indexing_partial.dump
  end

  # Return an appropriate source.
  #
  # If we have no explicit source, we'll check the index for one.
  #
  def source
    @source || @index.source
  end

  # Return the key format.
  #
  # If the source has no key format, and
  # none is defined on this category, ask
  # the index for one.
  #
  def key_format
    source.respond_to?(:key_format) && source.key_format || @key_format || @index.key_format
  end

  # Where the data is taken from.
  #
  def from
    @from || name
  end

  # The indexer is lazily generated and cached.
  #
  def indexer
    @indexer ||= source.respond_to?(:each) ? Indexers::Parallel.new(self) : Indexers::Serial.new(self)
  end

  # Returns an appropriate tokenizer.
  # If one isn't set on this category, will try the index,
  # and finally the default index tokenizer.
  #
  def tokenizer
    @tokenizer || @index.tokenizer
  end

  # Checks the caches for existence.
  #
  def check
    timed_exclaim "Checking #{identifier}."
    indexing_exact.raise_unless_cache_exists
    indexing_partial.raise_unless_cache_exists
  end

  # Deletes the caches.
  #
  def clear
    timed_exclaim "Deleting #{identifier}."
    indexing_exact.delete
    indexing_partial.delete
  end

  # Backup the caches.
  # (Revert with restore_caches)
  #
  def backup
    timed_exclaim "Backing up #{identifier}."
    indexing_exact.backup
    indexing_partial.backup
  end

  # Restore the caches.
  # (Revert with backup_caches)
  #
  def restore
    timed_exclaim "Restoring #{identifier}."
    indexing_exact.restore
    indexing_partial.restore
  end

end