# encoding: utf-8
#
require 'spec_helper'

describe Picky::Tokenizer do
  describe 'examples' do
    it 'leaves a dash alone by default' do
      tokenizer = described_class.new
      tokenizer.tokenize('title1-').should == [['title1-'], ['title1-']]
    end
    it 'works correctly' do
      tokenizer = described_class.new(normalizes_words: [[/\&/, 'and']])
      
      # Is this really correct? Shouldn't we split after normalizing? 
      #
      # Yes – we split using more information.
      #
      tokenizer.tokenize('M & M').should == [['m', 'and', 'm'], ['m', 'and', 'm']]
    end
    it 'works correctly' do
      tokenizer = described_class.new(stopwords: /\b(and)\b/, normalizes_words: [[/\&/, 'and']])
      
      # Is this really correct? Shouldn't we stop words after normalizing? 
      #
      # Yes – we do stopwords using more information.
      #
      tokenizer.tokenize('M & M').should == [['m', 'and', 'm'], ['m', 'and', 'm']]
    end
    it 'removes all stopwords if they do not occur alone' do
      tokenizer = described_class.new(stopwords: /\b(and|then)\b/)
      tokenizer.tokenize('and then').should == [[], []]
    end
    it 'does not remove a stopword if it occurs alone' do
      tokenizer = described_class.new(stopwords: /\b(and|then)\b/)
      tokenizer.tokenize('and').should == [['and'], ['and']]
    end
    it 'does not remove a stopword if it occurs alone (even with qualifier)' do
      tokenizer = described_class.new(stopwords: /\b(and|then)\b/)
      tokenizer.tokenize('title:and').should == [['title:and'], ['title:and']]
    end
    it 'does not remove a stopword if it occurs alone (even with qualifier)' do
      tokenizer = described_class.new(stopwords: /\b(and|then)\b/)
      tokenizer.tokenize('title:and').should == [['title:and'], ['title:and']]
    end
    it 'removes stopwords, then only lets through max words words' do
      tokenizer = described_class.new(stopwords: /\b(and|then|to|the)\b/, max_words: 2)
      tokenizer.tokenize('and then they went to the house').should == [['they', 'went'], ['they', 'went']]
    end
    it 'can take freaky splits_text_on options' do
      tokenizer = described_class.new(splits_text_on: /([A-Z]?[a-z]+)/, case_sensitive: false) # Explicit case, is false by default.
      tokenizer.tokenize('TOTALCamelCaseExample').should == [
        ["total", "camel", "case", "example"],
        ["total", "camel", "case", "example"]
      ]
    end
    it 'substitutes and removes in the right order' do
      tokenizer = described_class.new(
        substitutes_characters_with: Picky::CharacterSubstituters::WestEuropean.new,
        removes_characters: /e/
      )
      
      # Ä -> Ae -> A
      #
      tokenizer.tokenize('Ä ä').should == [['a', 'a'], ['a', 'a']]
    end
    it 'removes characters, then only lets through an ok sized token' do
      tokenizer = described_class.new(rejects_token_if: ->(token){ token.size >= 5 }, removes_characters: /e/)
      tokenizer.tokenize('hullo').should == [[], []]
      tokenizer.tokenize('hello').should == [['hllo'], ['hllo']]
    end
    it 'is case sensitive' do
      tokenizer = described_class.new(case_sensitive: true)
      tokenizer.tokenize('Kaspar codes').should == [['Kaspar', 'codes'], ['Kaspar', 'codes']]
    end
    it 'is case sensitive, also for removing characters' do
      tokenizer = described_class.new(case_sensitive: true, removes_characters: /K/)
      tokenizer.tokenize('Kaspar codes').should == [['aspar', 'codes'], ['aspar', 'codes']]
    end
  end
end