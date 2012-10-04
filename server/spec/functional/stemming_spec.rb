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
  end
end