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

  # Return an appropriate source.
  #
  def source
    @source || @index.source
  end

  # Return the key format.
  #
  # If the source has no key format, then
  # check for an explicit key format, and
  # if none is defined, ask the index for
  # one.
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

  # TODO This is a hack to get the parallel indexer working.
  #
  def categories
    [self]
  end

  # Returns an appropriate tokenizer.
  # If one isn't set on this category, will try the index,
  # and finally the default index tokenizer.
  #
  def tokenizer
    @tokenizer || @index.tokenizer || Tokenizers::Index.default
  end

  # Backup the caches.
  # (Revert with restore_caches)
  #
  def backup_caches
    timed_exclaim "Backing up #{identifier}."
    indexing_exact.backup
    indexing_partial.backup
  end

  # Restore the caches.
  # (Revert with backup_caches)
  #
  def restore_caches
    timed_exclaim "Restoring #{identifier}."
    indexing_exact.restore
    indexing_partial.restore
  end

  # Checks the caches for existence.
  #
  def check_caches
    timed_exclaim "Checking #{identifier}."
    indexing_exact.raise_unless_cache_exists
    indexing_partial.raise_unless_cache_exists
  end

  # Deletes the caches.
  #
  def clear_caches
    timed_exclaim "Deleting #{identifier}."
    indexing_exact.delete
    indexing_partial.delete
  end

  # We need to set what formatting method should be used.
  # Uses the one defined in the indexer.
  #
  # TODO Make this more dynamic.
  #
  def configure
    indexing_exact[:key_format] = self.key_format
    indexing_partial[:key_format] = self.key_format
  end

  # Indexes, creates the "prepared_..." file.
  #
  # TODO This step could already prepare the id (if a
  #      per category key_format is not really needed).
  #
  def prepare
    prepare_index_directory
    indexer.index
  end

  # Generates all caches for this category.
  #
  def cache
    prepare_index_directory
    generate_caches
  end

  # Generate the cache data.
  #
  def generate_caches
    configure
    generate_caches_from_source
    generate_partial
    generate_caches_from_memory
    dump_caches
    timed_exclaim %Q{"#{identifier}": Caching finished.}
  end
  def generate_caches_from_source
    indexing_exact.generate_caches_from_source
  end
  def generate_partial
    indexing_partial.generate_partial_from indexing_exact.index
  end
  def generate_caches_from_memory
    indexing_partial.generate_caches_from_memory
  end
  def dump_caches
    indexing_exact.dump
    indexing_partial.dump
  end

end