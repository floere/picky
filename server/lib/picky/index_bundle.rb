# Comfortable API convenience class, splits methods to indexes.
#
class IndexBundle # :nodoc:all

  attr_reader :indexes, :index_mapping, :indexing, :indexed

  delegate :size,
           :each,
           :to => :indexes

  delegate :analyze,
           :load_from_cache,
           :reload,
           :to => :indexed

  delegate :check_caches,
           :find,
           :index,
           :index_for_tests,
           :to => :indexing

  def initialize
    @indexes = []
    @index_mapping = {}

    @indexed  = Indexed::Indexes.new
    @indexing = Indexing::Indexes.new
  end

  def register index
    self.indexes << index
    self.index_mapping[index.name] = index

    indexing.register index.internal_indexing
    indexed.register  index.internal_indexed
  end

  def [] name
    name = name.to_sym

    self.index_mapping[name]
  end
  
  def to_s
    indexes.map &:to_stats
  end

end