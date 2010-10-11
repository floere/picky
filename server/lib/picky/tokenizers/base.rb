module Tokenizers
  
  # Defines tokenizing processes used both in indexing and querying.
  #
  class Base
    
    # Stopwords.
    #
    def self.stopwords regexp
      define_method :remove_stopwords do |text|
        text.gsub! regexp, ''
      end
      # Use this method if you don't want to remove
      # stopwords if it is just one word.
      #
      @@non_single_stopword_regexp = /^\b[\w:]+?\b[\.\*\~]?\s?$/
      define_method :remove_non_single_stopwords do |text|
        return text if text.match @@non_single_stopword_regexp
        remove_stopwords text
      end
    end
    def remove_stopwords text; end
    
    # Contraction.
    #
    def self.contracts_expressions what, to_what
      define_method :contract do |text|
        text.gsub! what, to_what
      end
    end
    def contract text; end
    
    # Illegals.
    #
    # TODO Should there be a legal?
    #
    def self.removes_characters regexp
      define_method :remove_illegals do |text|
        text.gsub! regexp, ''
      end
    end
    def remove_illegals text; end
    
    # Splitting.
    #
    def self.splits_text_on regexp
      define_method :split do |text|
        text.split regexp
      end
    end
    def split text; end
    
    # Normalizing.
    #
    def self.normalizes_words regexp_replaces
      define_method :normalize_with_patterns do |text|
        regexp_replaces.each do |regex, replace|
          # This should be sufficient
          #
          text.gsub!(regex, replace) and break
        end
        remove_after_normalizing_illegals text
        text
      end
    end
    def normalize_with_patterns text; end
    
    # Illegal after normalizing.
    #
    def self.removes_characters_after_splitting regexp
      define_method :remove_after_normalizing_illegals do |text|
        text.gsub! regexp, ''
      end
    end
    def remove_after_normalizing_illegals text; end
    
    # Returns a number of tokens, generated from the given text.
    #
    # Note:
    #  * preprocess, pretokenize are hooks
    #
    def tokenize text
      text   = preprocess text  # processing the text
      return empty_tokens if text.blank?
      words  = pretokenize text # splitting and preparations for tokenizing
      return empty_tokens if words.empty?
      tokens = tokens_for words # creating tokens / strings
               process tokens   # processing tokens / strings
    end
    
    # Hooks.
    #
    
    # Preprocessing.
    #
    def preprocess text; end
    # Pretokenizing.
    #
    def pretokenize text; end
    # Postprocessing.
    #
    def process tokens
      reject tokens    # Reject any tokens that don't meet criteria
      tokens
    end
    
    # Rejects blank tokens.
    #
    def reject tokens
      tokens.reject! &:blank?
    end
    # Converts words into real tokens.
    #
    def tokens_for words
      ::Query::Tokens.new words.collect! { |word| token_for word }
    end
    # Turns non-blank text into symbols.
    #
    def symbolize text
      text.blank? ? nil : text.to_sym
    end
    # Returns a tokens object.
    #
    def empty_tokens
      ::Query::Tokens.new
    end
    
  end
end