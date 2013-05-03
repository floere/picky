# encoding: utf-8
#

class Range
  def expand_with thing
    return (thing..thing) unless min
    if max < thing
      (min..thing)
    else
      thing < min ? (thing..max) : self
    end
  end
end

# Analyzes indexes (index bundles, actually).
#
class Analyzer

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
    bundle.load_inverted
    analysis[:__keys] = bundle.inverted.size
    cardinality :index, bundle.inverted
    index_analysis
    bundle.clear_inverted

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
    return unless can_calculate_cardinality? index

    key_length_sum = 0
    ids_length_sum = 0
    
    key_length = (1.0/0..0)
    ids_length = (1.0/0..0)

    index.each_pair do |key, ids|
      key_length = key_length.expand_with key.size
      key_length_sum += key.size
      ids_length = ids_length.expand_with ids.size
      ids_length_sum += ids.size
    end

    report_cardinality identifier, index, key_length, ids_length, key_length_sum, ids_length_sum
  end
  def report_cardinality identifier, index, key_length, ids_length, key_length_sum, ids_length_sum
    analysis_identifier = analysis[identifier] ||= {}
    analysis_identifier[:key_length]         = key_length
    analysis_identifier[:ids_length]         = ids_length
    analysis_identifier[:key_length_average] = key_length_sum.to_f / index.size
    analysis_identifier[:ids_length_average] = ids_length_sum.to_f / index.size    
  end
  
  def can_calculate_cardinality? index
    return if index.size.zero?
    return unless index.respond_to? :each_pair
    true
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
    return if !index.respond_to?(:size) || index.size.zero?
    return unless index.respond_to?(:each_pair)

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
    ary = ["index key cardinality:                #{"%9d" % analysis[:__keys]}"]
    return ary.join "\n" unless analysis[:index]
    ary << formatted(nil,       :key_length)
    ary << formatted('ids per', :ids_length)
    ary.join "\n"
  end
  
  def formatted description, key, index = :index
    what    = "%-40s" % ["index", description, "key length range (avg):"].compact.join(' ')
    range   = "%7s" % analysis[index][key]
    average = "%8s" % "(#{analysis[index][:"#{key}_average"].round(2)})"
    what + range + average
  end
  
  def weights_to_s
    return unless analysis[:weights]
    what    = "%-30s" % "weights range (avg):"
    range   = "%17s" % analysis[:weights][:weight_range]
    average = "%8s" % "(#{analysis[:weights][:weight_average].round(2)})"
    what + range + average
  end
  
  def similarity_to_s
    return unless analysis[:similarity]
    formatted('similarity', :key_length, :similarity)
  end
  
  def configuration_to_s
    # analysis[:configuration]
  end

end