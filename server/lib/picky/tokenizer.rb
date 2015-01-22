# encoding: utf-8
#
module Picky

  # Defines tokenizing processes used both in indexing and querying.
  #
  class Tokenizer

    extend Picky::Helpers::Identification
    include API::Tokenizer::CharacterSubstituter
    include API::Tokenizer::Stemmer

    def self.default_indexing_with options = {}
      @indexing = from options
    end
    def self.indexing
      @indexing ||= new
    end

    def self.default_searching_with options = {}
      @searching = from options
    end
    def self.searching
      @searching ||= new
    end
    
    def self.from thing, index_name = nil, category_name = nil
      return unless thing
        
      if thing.respond_to? :tokenize
        thing
      else
        if thing.respond_to? :[]
          Picky::Tokenizer.new thing
        else
          raise <<-ERROR
indexing options #{identifier_for(index_name, category_name)}should be either
* a Hash
or
* an object that responds to #tokenize(text) => [[token1, token2, ...], [original1, original2, ...]]
ERROR
        end
      end
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
Stems?              #{@stemmer ? "Yes, using #{@stemmer}." : '-' }
Case sensitive?     #{@case_sensitive ? "Yes." : "-"}
      TOKENIZER
    end

    # Stopwords.
    #
    # We even allow Strings even if it's hard to understand.
    #
    def stopwords regexp
      check_argument_in __method__, [Regexp, String, FalseClass], regexp
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
      check_argument_in __method__, [Regexp, FalseClass], regexp
      @removes_characters_regexp = regexp
    end
    def remove_illegals text
      text.gsub! @removes_characters_regexp, EMPTY_STRING if @removes_characters_regexp
      text
    end

    # Splitting.
    #
    # We allow Strings, Regexps, and things that respond to #split.
    #
    # Note: We do not test against to_str since symbols do not work with String#split.
    #
    def splits_text_on thing
      raise ArgumentError.new "#{__method__} takes a Regexp or a thing that responds to #split as argument, not a #{thing.class}." unless Regexp === thing || thing.respond_to?(:split)
      @splits_text_on = if thing.respond_to? :split
        thing
      else
        RegexpWrapper.new thing
      end
    end
    def split text
      # Does not create a new string if nothing is split.
      #
      @splits_text_on.split text
    end

    # Normalizing.
    #
    # We only allow arrays.
    #
    # TODO 5.0 Rename to normalizes(config) or normalizes_words
    # TODO 5.0 Rename to normalize(text) or normalize_words
    #
    def normalizes_words regexp_replaces
      raise ArgumentError.new "#{__method__} takes an Array of replaces as argument, not a #{regexp_replaces.class}." unless regexp_replaces.respond_to?(:to_ary) || regexp_replaces.respond_to?(:normalize_with_patterns)
      @normalizes_words_regexp_replaces = regexp_replaces
    end
    def normalize_with_patterns text
      return text unless @normalizes_words_regexp_replaces # TODO Remove.

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
      @substituter = extract_character_substituter substituter
    end
    def substitute_characters text
      substituter?? substituter.substitute(text) : text
    end
    
    # Stems tokens with this stemmer.
    #
    def stems_with stemmer
      @stemmer = extract_stemmer stemmer
    end
    def stem text
      stemmer?? stemmer.stem(text) : text
    end

    # Reject tokens after tokenizing based on the given criteria.
    #
    def rejects_token_if condition
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
    def check_argument_in method, types, argument, &condition
      types = [*types]
      unless types.any? { |type| type === argument }
        raise ArgumentError.new "Application##{method} takes any of #{types.join(', ')} as argument, but not a #{argument.class}."
      end
    end

    attr_reader :substituter, :stemmer
    alias substituter? substituter
    alias stemmer? stemmer

    def initialize options = {}
      options = default_options.merge options
      options.each do |method_name, value|
        send method_name, value unless value.nil?
      end
    rescue NoMethodError => e
      raise <<-ERROR
The option "#{e.name}" is not a valid option for a Picky tokenizer.
Please see https://github.com/floere/picky/wiki/Indexing-configuration for valid options.
A short overview:
  removes_characters          /regexp/
  stopwords                   /regexp/
  splits_text_on              /regexp/ or "String", default /\s/
  normalizes_words            [[/replace (this)/, 'with this \\1'], ...]
  rejects_token_if            Proc/lambda, default :empty?.to_proc
  substitutes_characters_with Picky::CharacterSubstituter or responds to #substitute(String)
  stems_with                  Instance responds to #stem(String)
  case_sensitive              true/false

ERROR
    end
    def default_options
      {
        splits_text_on: /\s/,
        rejects_token_if: :empty?.to_proc
      }
    end

    # Returns a number of tokens, generated from the given text,
    # based on the parameters given.
    #
    # Returns:
    #  [[:token1, :token2], ["Original1", "Original2"]]
    #
    def tokenize text
      text = preprocess text.to_s # processing the text
      return empty_tokens if text.empty? # TODO blank?
      words = pretokenize text # splitting and preparations for tokenizing
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
      words.collect! { |word| stem word } if stemmer? # Usually only done in indexing step.
      words
    end

    # Returns empty tokens.
    #
    def empty_tokens
      [[], []]
    end

  end

end