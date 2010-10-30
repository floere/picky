module Query

  # Describes the combination of a token (the text) and
  # the index (the bundle).
  #
  # A combination is a single part of an allocation.
  #
  # An allocation consists of a number of combinations.
  #
  class Combination

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
    # TODO Really cache?
    #
    def weight
      @weight ||= @bundle.weight(@text)
    end
    
    # Returns an array of ids for the given text.
    #
    # TODO Really cache?
    #
    def ids
      @ids ||= @bundle.ids(@text)
    end
    
    # The identifier for this combination.
    #
    def identifier
      @category_name
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
      [identifier, *@token.to_result]
    end
    
    # Example:
    #  "exact title:Peter*:peter"
    #
    def to_s
      "#{bundle.identifier} #{to_result.join(':')}"
    end
    
  end

end