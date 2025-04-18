# encoding: utf-8

require 'spec_helper'

describe 'similarity' do
  it 'does Soundex' do
    index = Picky::Index.new :phonetic do
      indexing removes_characters: /[^a-z\s]/i
      category :text, similarity: Picky::Similarity::Soundex.new(1)
    end

    index.replace_from id: 1, text: 'Peter'

    try = Picky::Search.new index

    # No ~, no similarity.
    #
    try.search('text:petor').ids.should == []

    # Finds soundex-similar text.
    #
    try.search('text:petor~').ids.should == [1]

    # Finds the identity.
    #
    try.search('text:peter~').ids.should == [1]
  end
  it 'does Metaphone' do
    index = Picky::Index.new :phonetic do
      indexing removes_characters: /[^a-z\s]/i
      category :text, similarity: Picky::Similarity::Metaphone.new(1)
    end

    index.replace_from id: 1, text: 'Peter'

    try = Picky::Search.new index

    # No ~, no similarity.
    #
    try.search('text:pdr').ids.should == []

    # Finds soundex-similar text.
    #
    try.search('text:pdr~').ids.should == [1]

    # Finds the identity.
    #
    try.search('text:peter~').ids.should == [1]
  end
  it 'does DoubleMetaphone' do
    index = Picky::Index.new :phonetic do
      indexing removes_characters: /[^a-z\s]/i
      category :text, similarity: Picky::Similarity::DoubleMetaphone.new(1)
    end

    index.replace_from id: 1, text: 'Peter'

    try = Picky::Search.new index

    # No ~, no similarity.
    #
    try.search('text:pdr').ids.should == []

    # Finds soundex-similar text.
    #
    try.search('text:pdr~').ids.should == [1]

    # Finds the identity.
    #
    try.search('text:peter~').ids.should == [1]
  end
end
