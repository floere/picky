# encoding: utf-8
#

# Analyzes indexes (index bundles, actually).
#
class Analyzer # :nodoc:all

  attr_reader :analysis, :comments

  #
  #
  def initialize
    @analysis = {}
    @comments = []
  end

  #
  #
  def analyze bundle
    bundle.load_index
    analysis[:__keys] = bundle.size
    cardinality :index, bundle.inverted
    index_analysis
    bundle.clear_index

    bundle.load_weights
    weights bundle.weights
    weights_analysis
    bundle.clear_weights

    bundle.load_similarity
    cardinality :similarity, bundle.similarity
    bundle.clear_similarity

    # bundle.load_configuration
    # analysis[:configuration] = bundle.configuration
    # bundle.clear_configuration

    self
  end
  def cardinality identifier, index
    return if index.size.zero?

    key_length_average = 0
    ids_length_average = 0

    min_ids_length = 1.0/0 # Infinity
    max_ids_length =     0
    min_key_length = 1.0/0 # Infinity
    max_key_length =     0

    key_size, ids_size =
    index.each_pair do |key, ids|
      key_size = key.size
      if key_size < min_key_length
        min_key_length = key_size
      else
        max_key_length = key_size if key_size > max_key_length
      end
      key_length_average += key_size

      ids_size = ids.size
      if ids_size < min_ids_length
        min_ids_length = ids_size
      else
        max_ids_length = ids_size if ids_size > max_ids_length
      end
      ids_length_average += ids_size
    end
    index_size = index.size
    key_length_average = key_length_average.to_f / index_size
    ids_length_average = ids_length_average.to_f / index_size

    analysis[identifier] ||= {}
    analysis[identifier][:key_length]         = (min_key_length..max_key_length)
    analysis[identifier][:ids_length]         = (min_ids_length..max_ids_length)
    analysis[identifier][:key_length_average] = key_length_average
    analysis[identifier][:ids_length_average] = ids_length_average
  end
  def index_analysis
    return unless analysis[:index]

    if analysis[:__keys] < 100
      comments << "\033[33mVery small index (< 100 keys).\033[m"
    end

    range = analysis[:index][:key_length]
    case range.min
    when 1
      comments << "\033[33mIndex matches single characters.\033[m"
    end
  end
  def weights index
    return if index.size.zero?

    min_weight = 1.0/0 # Infinity
    max_weight =   0.0

    weight_average = 0

    index.each_pair do |key, value|
      if value < min_weight
        min_weight = value
      else
        max_weight = value if value > max_weight
      end
      weight_average += value
    end

    weight_average = weight_average / index.size

    analysis[:weights] ||= {}
    analysis[:weights][:weight_range]   = (min_weight..max_weight)
    analysis[:weights][:weight_average] = weight_average
  end
  def weights_analysis
    return unless analysis[:weights]

    range = analysis[:weights][:weight_range]

    case range.max
    when 0.0
      comments << "\033[31mThere's only one id per key – you'll only get single results.\033[m"
    end
  end

  #
  #
  def to_s
    [*comments, index_to_s, weights_to_s, similarity_to_s, configuration_to_s].compact.join "\n"
  end
  def index_to_s
    return if analysis[:__keys].zero?
    [
      "index key cardinality:                #{"%10d" % analysis[:__keys]}",
      "index key length range (avg):         #{"%10s" % analysis[:index][:key_length]} (#{analysis[:index][:key_length_average].round(2)})",
      "index ids per key length range (avg): #{"%10s" % analysis[:index][:ids_length]} (#{analysis[:index][:ids_length_average].round(2)})"
    ].join("\n")
  end
  def weights_to_s
    return unless analysis[:weights]
    %Q{weights range (avg):                  #{"%10s" % analysis[:weights][:weight_range]} (#{analysis[:weights][:weight_average].round(2)})}
  end
  def similarity_to_s
    return unless analysis[:similarity]
    %Q{similarity key length range (avg):    #{"%10s" % analysis[:similarity][:key_length]} (#{analysis[:similarity][:key_length_average].round(2)})}
  end
  def configuration_to_s
    # analysis[:configuration]
  end

end