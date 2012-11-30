# encoding: utf-8
#
require 'spec_helper'

describe 'custom delimiters' do
  
  after(:each) do
    Picky::Query::Token.partial_character = '\*'
    Picky::Query::Token.no_partial_character = '"'
    Picky::Query::Token.similar_character = '~'
    Picky::Query::Token.no_similar_character = '"'
    Picky::Query::Token.range_character = '-'
    Picky::Query::Token.qualifier_text_delimiter = ':'
    Picky::Query::Token.qualifiers_delimiter = ','
  end

  it 'offers custom partial delimiters to be set' do
    index = Picky::Index.new :custom_delimiters do
      category :text1
      category :text2
    end

    index.add Struct.new(:id, :text1, :text2).new(1, 'hello', 'world')

    try = Picky::Search.new index
    try.search("hell world").ids.should == []
    try.search("hell* world").ids.should == [1]
    try.search("hello world").ids.should == [1]
    
    try.search("hell! world").ids.should == []
    Picky::Query::Token.partial_character = '!'
    try.search("hell! world").ids.should == [1]
    
    try.search('hell!" world').ids.should == []
    Picky::Query::Token.no_partial_character = '\?'
    try.search('hell!? world').ids.should == []
  end
  
  it 'offers custom similar delimiters to be set' do
    index = Picky::Index.new :custom_delimiters do
      category :text1, similarity: Picky::Similarity::Soundex.new
      category :text2
    end

    index.add Struct.new(:id, :text1, :text2).new(1, 'hello', 'world')

    try = Picky::Search.new index
    try.search("hell world").ids.should == []
    try.search("hell~ world").ids.should == [1]
    try.search("hello world").ids.should == [1]
    
    try.search("hell? world").ids.should == []
    Picky::Query::Token.similar_character = '\?'
    try.search("hell? world").ids.should == [1]
    
    try.search('hell?" world').ids.should == []
    Picky::Query::Token.no_partial_character = '!'
    try.search('hell?! world').ids.should == []
  end
  
  it 'offers custom similar delimiters to be set' do
    index = Picky::Index.new :custom_delimiters do
      category :text1, similarity: Picky::Similarity::Soundex.new
      category :text2
    end

    index.add Struct.new(:id, :text1, :text2).new(1, 'hello world', 'world')

    try = Picky::Search.new index
    try.search("text1:hello text2:world").ids.should == [1]
    
    try.search("text1?hello text2?world").ids.should == []
    Picky::Query::Token.qualifier_text_delimiter = '?'
    try.search("text1?hello text2?world").ids.should == [1]
    
    try.search("text1|text2?hello text2?world").ids.should == []
    Picky::Query::Token.qualifiers_delimiter = '|'
    try.search("text1|text2?hello text2?world").ids.should == [1]
  end
  
  it 'offers custom range characters to be set' do
    index = Picky::Index.new :custom_range_character do
      category :year
    end

    rangy = Struct.new :id, :year
    
    index.add rangy.new(1, 1977)
    index.add rangy.new(2, 1989)
    index.add rangy.new(3, 2001)
    index.add rangy.new(4, 2012)
    index.add rangy.new(4, 3000)

    try = Picky::Search.new index
    try.search("1980-2015").ids.should == [2,3,4]
    
    try.search("1980…2015").ids.should == []
    Picky::Query::Token.range_character = "…"
    try.search("1980…2015").ids.should == [2,3,4]
  end
end
