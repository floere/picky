module Tokenizers
  
  # Defines tokenizing processes used both in indexing and querying.
  #
  class Base
    
    # TODO use frozen EMPTY_STRING for ''
    #
    
    # Stopwords.
    #
    def stopwords regexp
      @remove_stopwords_regexp = regexp
    end
    def remove_stopwords text
      text.gsub! @remove_stopwords_regexp, '' if @remove_stopwords_regexp
    end
    @@non_single_stopword_regexp = /^\b[\w:]+?\b[\.\*\~]?\s?$/
    def remove_non_single_stopwords text
      return text if text.match @@non_single_stopword_regexp
      remove_stopwords text
    end
    
    # Contraction.
    #
    def contracts_expressions what, to_what
      @contract_what    = what
      @contract_to_what = to_what
    end
    def contract text
      text.gsub! @contract_what, @contract_to_what if @contract_what
    end
    
    # Illegals.
    #
    # TODO Should there be a legal?
    #
    def removes_characters regexp
      @removes_characters_regexp = regexp
    end
    def remove_illegals text
      text.gsub! @removes_characters_regexp, '' if @removes_characters_regexp
      text
    end
    
    # Splitting.
    #
    def splits_text_on regexp
      @splits_text_on_regexp = regexp
    end
    def split text
      text.split @splits_text_on_regexp
    end
    
    # Normalizing.
    #
    def normalizes_words regexp_replaces
      @normalizes_words_regexp_replaces
    end
    def normalize_with_patterns text
      return text unless @normalizes_words_regexp_replaces
      
      @normalizes_words_regexp_replaces.each do |regex, replace|
        # This should be sufficient
        #
        text.gsub!(regex, replace) and break
      end
      remove_after_normalizing_illegals text
      text
    end
    
    # Illegal after normalizing.
    #
    def removes_characters_after_splitting regexp
      @removes_characters_after_splitting_regexp = regexp
    end
    def remove_after_normalizing_illegals text
      text.gsub! @removes_characters_after_splitting_regexp, '' if @removes_characters_after_splitting_regexp
    end
    
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
    
    attr_accessor :substituter
    alias substituter? substituter
    
    def initialize substituter = UmlautSubstituter.new
      @substituter = substituter
      
      # TODO Default handling.
      #
      splits_text_on(/\s/)
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