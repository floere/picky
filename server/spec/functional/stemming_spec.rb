require 'spec_helper'

require 'stemmer'
require 'lingua/stemmer'

describe 'stemming' do
  describe 'per-index stemming' do
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

    it 'works correctly' do
      tokenizer = Picky::Tokenizer.new(stems_with: stemmer)

      # Is this really correct? Shouldn't we split after normalizing?
      #
      # Yes – we split using more information.
      #
      tokenizer.stem('computers').should
      tokenizer.stem('computing').should
      tokenizer.stem('computed').should
      tokenizer.stem('computer').should  == 'comput'
    end

    # This tests the stems_with option.
    #
    it 'stems right (API conform Stemmer)' do
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

      index.replace_from id: 1, text: 'Hello good Sirs, these things here need stems to work!'
      index.replace_from id: 2, text: 'Stemming Lemming!'

      try = Picky::Search.new index

      # Stems for both, so finds both.
      #
      try.search('text:stemming').ids.should
      try.search('text:lem').ids.should == [2]
    end

    # This tests the stems_with option.
    #
    it 'stems right (Lingua::Stemmer.new)' do
      index = Picky::Index.new :stemming do
        # Be aware that if !s are not removed from
        # eg. Lemming!, then stemming won't work.
        #
        indexing removes_characters: /[^a-z\s]/i,
                 stems_with: Lingua::Stemmer.new # Both stem
        category :text
      end

      index.replace_from id: 1, text: 'Hello good Sirs, these things here need stems to work!'
      index.replace_from id: 2, text: 'Stemming Lemming!'

      try = Picky::Search.new index

      try.search('text:stemming').ids.should
      try.search('text:lem').ids.should == [2]
    end
  end

  describe 'per-category stemming' do
    describe 'mixed stemming categories' do
      it 'stems some but not others' do
        index = Picky::Index.new :stemming do
          # Be aware that if !s are not removed from
          # eg. Lemming!, then stemming won't work.
          #
          indexing removes_characters: /[^a-z\s]/i
          category :text1,
                   partial: Picky::Partial::None.new,
                   indexing: { stems_with: Lingua::Stemmer.new }
          category :text2,
                   partial: Picky::Partial::None.new
        end

        index.replace_from id: 1, text1: 'stemming', text2: 'ios'
        index.replace_from id: 2, text1: 'ios', text2: 'stemming'

        try = Picky::Search.new index

        try.search('stemming').ids.should
        try.search('stemmin').ids.should
        try.search('stemmi').ids.should
        try.search('stemm').ids.should
        try.search('stem').ids.should

        try.search('ios').ids.should
        try.search('io').ids.should
        try.search('i').ids.should

        try.search('text1:stemming').ids.should
        try.search('text2:ios').ids.should

        try.search('text1:ios').ids.should
        try.search('text2:stemming').ids.should

        try.search('text1:stem').ids.should
        try.search('text2:io').ids.should

        try.search('text1:io').ids.should
        try.search('text2:stem').ids.should == []
      end
    end
    describe 'multiple stemmers' do
      it 'caching works' do
        do_nothing_stemmer = Class.new do
          def stem(text)
            text
          end
        end.new

        index = Picky::Index.new :stemming do
          # Be aware that if !s are not removed from
          # eg. Lemming!, then stemming won't work.
          #
          indexing removes_characters: /[^a-z\s]/i
          category :text1,
                   partial: Picky::Partial::None.new,
                   indexing: { stems_with: Lingua::Stemmer.new }
          category :text2,
                   partial: Picky::Partial::None.new,
                   indexing: { stems_with: do_nothing_stemmer }
        end

        index.replace_from id: 1, text1: 'stemming', text2: 'ios'
        index.replace_from id: 2, text1: 'ios', text2: 'stemming'

        try = Picky::Search.new index

        try.search('stemming').ids.should
        try.search('stemmin').ids.should
        try.search('stemmi').ids.should
        try.search('stemm').ids.should
        try.search('stem').ids.should

        try.search('ios').ids.should
        try.search('io').ids.should
        try.search('i').ids.should

        try.search('text1:stemming').ids.should
        try.search('text2:ios').ids.should

        try.search('text1:ios').ids.should
        try.search('text2:stemming').ids.should

        try.search('text1:stem').ids.should
        try.search('text2:io').ids.should

        try.search('text1:io').ids.should
        try.search('text2:stem').ids.should == []
      end
    end
  end
end
