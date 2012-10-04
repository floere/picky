# encoding: utf-8
#
require 'spec_helper'

require 'stemmer'

describe 'stemming' do
  let(:stemmer) {
    # Fast stemmer does not conform with the API.
    #
    module Stemmer
      class << self
        alias_method :stem, :stem_word
      end
    end
    Stemmer
  }
  
  describe 'examples' do
    it 'works correctly' do
      tokenizer = Picky::Tokenizer.new(stems_with: stemmer)
      
      # Is this really correct? Shouldn't we split after normalizing? 
      #
      # Yes – we split using more information.
      #
      tokenizer.stem('computers').should == 'comput'
      tokenizer.stem('computing').should == 'comput'
      tokenizer.stem('computed').should  == 'comput'
      tokenizer.stem('computer').should  == 'comput'
    end
    
    # This tests the weights option.
    #
    it 'stems right' do
      # Fix the Stemmer API.
      #
      module Stemmer
        class << self
          # stem_word is a bit silly, what else would you stem???
          #
          alias_method :stem, :stem_word
        end
      end
      
      index = Picky::Index.new :stemming do
        # Be aware that if !s are not removed from
        # eg. Lemming!, then stemming won't work.
        #
        indexing removes_characters: /[^a-z\s]/i,
                 stems_with: Stemmer
        category :text
      end
      
      index.replace_from id: 1, text: "Hello good Sirs, these things here need stems to work!"
      index.replace_from id: 2, text: "Stemming Lemming!"

      try = Picky::Search.new index
      
      # If you don't stem in the search, it should not be found!
      #
      try.search("text:stemming").ids.should == []

      try = Picky::Search.new index do
        searching stems_with: Stemmer
      end
      
      # With stemming in search and indexing, it works :)
      #
      try.search("text:stemming").ids.should == [2, 1]
      try.search("text:lem").ids.should == [2]
    end
  end
end