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
      text
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
      @normalizes_words_regexp_replaces = regexp_replaces
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
    
    # Substitute Characters with this substituter.
    #
    # Default is European Character substitution.
    #
    def substitutes_characters_with substituter = CharacterSubstitution::European.new
      # TODO Raise if it doesn't quack substitute?
      @substituter = substituter
    end
    def substitute_characters text
      substituter?? substituter.substitute(text) : text 
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
    
    attr_reader :substituter
    alias substituter? substituter
    
    def initialize options = {}
      removes_characters options[:removes_characters]                                 if options[:removes_characters]
      contracts_expressions *options[:contracts_expressions]                          if options[:contracts_expressions]
      stopwords options[:stopwords]                                                   if options[:stopwords]
      normalizes_words options[:normalizes_words]                                     if options[:normalizes_words]
      removes_characters_after_splitting options[:removes_characters_after_splitting] if options[:removes_characters_after_splitting]
      substitutes_characters_with options[:substitutes_characters_with]               if options[:substitutes_characters_with]
      
      # Defaults.
      #
      splits_text_on options[:splits_text_on] || /\s/
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