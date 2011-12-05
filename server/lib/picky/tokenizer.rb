# encoding: utf-8
#
module Picky

  # Defines tokenizing processes used both in indexing and querying.
  #
  class Tokenizer

    def self.index_default= new_default
      @index_default = new_default
    end
    def self.index_default
      @index_default ||= new
    end

    def self.query_default= new_default
      @query_default = new_default
    end
    def self.query_default
      @query_default ||= new
    end

    def to_s
      reject_condition_location = @reject_condition.to_s[/:(\d+) \(lambda\)/, 1]
      <<-TOKENIZER
Removes characters: #{@removes_characters_regexp ? "/#{@removes_characters_regexp.source}/" : '-'}
Stopwords:          #{@remove_stopwords_regexp ? "/#{@remove_stopwords_regexp.source}/" : '-'}
Splits text on:     #{@splits_text_on.respond_to?(:source) ? "/#{@splits_text_on.source}/" : (@splits_text_on ? @splits_text_on : '-')}
Normalizes words:   #{@normalizes_words_regexp_replaces ? @normalizes_words_regexp_replaces : '-'}
Rejects tokens?     #{reject_condition_location ? "Yes, see line #{reject_condition_location} in app/application.rb" : '-'}
Substitutes chars?  #{@substituter ? "Yes, using #{@substituter}." : '-' }
Case sensitive?     #{@case_sensitive ? "Yes." : "-"}
      TOKENIZER
    end

    # Stopwords.
    #
    # We only allow regexps (even if string would be okay
    # too for gsub! - it's too hard to understand)
    #
    def stopwords regexp
      check_argument_in __method__, Regexp, regexp
      @remove_stopwords_regexp = regexp
    end
    def remove_stopwords text
      text.gsub! @remove_stopwords_regexp, EMPTY_STRING if @remove_stopwords_regexp
      text
    end
    @@non_single_stopword_regexp = /^\b[\w:]+?\b[\.\*\~]?\s?$/
    def remove_non_single_stopwords text
      return text unless @remove_stopwords_regexp
      return text if text.match @@non_single_stopword_regexp
      remove_stopwords text
    end

    # Illegals.
    #
    # We only allow regexps (even if string would be okay
    # too for gsub! - it's too hard to understand)
    #
    def removes_characters regexp
      check_argument_in __method__, Regexp, regexp
      @removes_characters_regexp = regexp
    end
    def remove_illegals text
      text.gsub! @removes_characters_regexp, EMPTY_STRING if @removes_characters_regexp
      text
    end

    # Splitting.
    #
    # We allow Strings and Regexps.
    # Note: We do not test against to_str since symbols do not work with String#split.
    #
    def splits_text_on regexp_or_string
      raise ArgumentError.new "#{__method__} takes a Regexp or String as argument, not a #{regexp_or_string.class}." unless Regexp === regexp_or_string || String === regexp_or_string
      @splits_text_on = regexp_or_string
    end
    def split text
      text.split @splits_text_on
    end

    # Normalizing.
    #
    # We only allow arrays.
    #
    def normalizes_words regexp_replaces
      raise ArgumentError.new "#{__method__} takes an Array of replaces as argument, not a #{regexp_replaces.class}." unless regexp_replaces.respond_to?(:to_ary)
      @normalizes_words_regexp_replaces = regexp_replaces
    end
    def normalize_with_patterns text
      return text unless @normalizes_words_regexp_replaces

      @normalizes_words_regexp_replaces.each do |regex, replace|
        # This should be sufficient
        #
        text.gsub!(regex, replace) and break
      end

      text
    end
    def normalize_with_patterns?
      @normalizes_words_regexp_replaces
    end

    # Substitute Characters with this substituter.
    #
    # Default is European Character substitution.
    #
    def substitutes_characters_with substituter = CharacterSubstituters::WestEuropean.new
      raise ArgumentError.new "The substitutes_characters_with option needs a character substituter, which responds to #substitute." unless substituter.respond_to?(:substitute)
      @substituter = substituter
    end
    def substitute_characters text
      substituter?? substituter.substitute(text) : text
    end

    # Reject tokens after tokenizing based on the given criteria.
    #
    def rejects_token_if &condition
      @reject_condition = condition
    end
    def reject tokens
      tokens.reject! &@reject_condition
    end

    # Case sensitivity.
    #
    # Note: If false, simply downcases the data/query.
    #
    def case_sensitive case_sensitive
      @case_sensitive = case_sensitive
    end
    def downcase?
      !@case_sensitive
    end

    # The maximum amount of words
    # to pass into the search engine.
    #
    def max_words amount
      @max_words = amount
    end
    def cap words
      words.slice!(@max_words..-1) if cap?(words)
    end
    def cap? words
      @max_words && words.size > @max_words
    end

    # Checks if the right argument type has been given.
    #
    def check_argument_in method, type, argument, &condition
      raise ArgumentError.new "Application##{method} takes a #{type} as argument, not a #{argument.class}." unless type === argument
    end

    attr_reader :substituter
    alias substituter? substituter

    def initialize options = {}
      substitutes_characters_with options[:substitutes_characters_with] if options[:substitutes_characters_with]
      removes_characters options[:removes_characters]                   if options[:removes_characters]
      stopwords options[:stopwords]                                     if options[:stopwords]
      splits_text_on options[:splits_text_on]                           || /\s/
      normalizes_words options[:normalizes_words]                       if options[:normalizes_words]
      max_words options[:max_words]
      rejects_token_if &(options[:rejects_token_if]                     || :blank?)
      case_sensitive options[:case_sensitive]                           unless options[:case_sensitive].nil?
    end

    # Returns a number of tokens, generated from the given text,
    # based on the parameters given.
    #
    # Returns:
    #  [[:token1, :token2], ["Original1", "Original2"]]
    #
    def tokenize text
      text   = preprocess text.to_s # processing the text
      return empty_tokens if text.blank?
      words  = pretokenize text # splitting and preparations for tokenizing
      return empty_tokens if words.empty?
      tokens = tokens_for words # creating tokens / strings
      [tokens, words]
    end

    # Default preprocessing hook.
    #
    # Does:
    # 1. Character substitution.
    # 2. Remove illegal expressions.
    # 3. Remove non-single stopwords. (Stopwords that occur with other words)
    #
    def preprocess text
      text = substitute_characters text
      remove_illegals text
      # We do not remove single stopwords e.g. in the indexer for
      # an entirely different reason than in the query tokenizer.
      # An indexed thing with just name "UND" (a possible stopword)
      # should not lose its name.
      #
      remove_non_single_stopwords text
      text
    end

    # Pretokenizing.
    #
    # Does:
    #  * Split the text into words.
    #  * Cap the amount of tokens if max_words is set.
    #
    def pretokenize text
      words = split text
      words.collect! { |word| normalize_with_patterns word } if normalize_with_patterns?
      reject words
      cap words if cap?(words)
      words
    end

    # Downcases.
    #
    def tokens_for words
      words.collect! { |word| word.downcase!; word } if downcase?
      words
    end

    # Returns empty tokens.
    #
    def empty_tokens
      [[], []]
    end

  end

end