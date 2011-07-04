module Query

  # Describes the combination of a token (the text) and
  # the index (the bundle): [text, index_bundle]
  #
  # A combination is a single part of an allocation:
  # [..., [text2, index_bundle2], ...]
  #
  # An allocation consists of a number of combinations:
  # [[text1, index_bundle1], [text2, index_bundle2], [text3, index_bundle1]]
  #
  class Combination # :nodoc:all

    attr_reader :token, :bundle, :category_name

    def initialize token, category
      @token         = token
      @category_name = category.name
      @bundle        = category.bundle_for token
      @text          = @token.text # don't want to use reset_similar already
    end
  
    # Note: Required for uniq!
    #
    def hash
      [@token.to_s, @bundle].hash
    end
  
    # Returns the weight of this combination.
    #
    # Note: Caching is most of the time useful.
    #
    def weight
      @weight ||= @bundle.weight(@text)
    end
  
    # Returns an array of ids for the given text.
    #
    # Note: Caching is most of the time useful.
    #
    def ids
      @ids ||= @bundle.ids(@text)
    end
  
    # The identifier for this combination.
    #
    def identifier
      "#{bundle.identifier}:#{@token.identifier}"
    end
  
    # Is the identifier in the given identifiers?
    #
    def in? identifiers
      identifiers.include? identifier
    end

    # Combines the category names with the original names.
    # [
    #  [:title,    'Flarbl', :flarbl],
    #  [:category, 'Gnorf',  :gnorf]
    # ]
    #
    def to_result
      [@category_name, *@token.to_result]
    end
  
    # Example:
    #  "exact title:Peter*:peter"
    #
    def to_s
      "#{bundle.identifier} #{to_result.join(':')}"
    end
  
  end

end