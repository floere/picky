# Registers the indexes held at runtime, for queries.
#
class Indexes

  instance_delegate :load_from_cache,
                    :reload,
                    :analyze

  each_delegate :load_from_cache,
                :to => :indexes

  # Reloads all indexes, one after another,
  # in the order they were added.
  #
  alias reload load_from_cache

end