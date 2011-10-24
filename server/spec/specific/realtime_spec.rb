# encoding: utf-8
#
require 'spec_helper'

describe "Realtime Indexing" do
  
  class Book
    attr_reader :id, :title, :author
    def initialize id, title, author
      @id, @title, @author = id, title, author
    end
  end
  
  let(:index) { Picky::Index.new(:test) { source []; category :title; category :author } }
  let(:books) { Picky::Search.new index }
  
  before(:each) do
    index.add Book.new(1, "Title", "Author")
  end
  
  context 'with partial' do
    it 'finds the first entry' do
      books.search('Titl').ids.should == [1]
    end

    it 'allows removing something' do
      index.remove 1
    end
    it 'is not findable anymore after removing' do
      books.search('Titl').ids.should == [1]

      index.remove 1

      books.search('Titl').ids.should == []
    end

    it 'allows adding something' do
      index.add Book.new(2, "Title2", "Author2")
    end
    it 'is findable after adding' do
      books.search('Titl').ids.should == [1]

      index.add Book.new(2, "Title New", "Author New")

      books.search('Titl').ids.should == [2,1]
    end

    it 'allows replacing something' do
      index.replace Book.new(1, "Title New", "Author New")
    end
    it 'is findable after replacing' do
      books.search('Ne').ids.should == []

      index.replace Book.new(1, "Title New", "Author New")

      books.search('Ne').ids.should == [1, 1]
    end
    it 'handles more complex cases' do
      books.search('Ne').ids.should == []

      index.replace Book.new(1, "Title New", "Author New")

      books.search('title:Ne').ids.should == [1]
    end
  end
  
  context 'non-partial' do
    it 'finds the first entry' do
      books.search('Titl').ids.should == [1]
    end

    it 'allows removing something' do
      index.remove 1
    end
    it 'is not findable anymore after removing' do
      books.search('Titl').ids.should == [1]

      index.remove 1

      books.search('Titl').ids.should == []
    end

    it 'allows adding something' do
      index.add Book.new(2, "Title2", "Author2")
    end
    it 'is findable after adding' do
      books.search('Titl').ids.should == [1]

      index.add Book.new(2, "Title New", "Author New")

      books.search('Titl').ids.should == [2,1]
    end

    it 'allows replacing something' do
      index.replace Book.new(1, "Title New", "Author New")
    end
    it 'is findable after replacing' do
      books.search('Ne').ids.should == []

      index.replace Book.new(1, "Title New", "Author New")

      books.search('Ne').ids.should == [1, 1]
    end
    it 'handles more complex cases' do
      books.search('Ne').ids.should == []

      index.replace Book.new(1, "Title New", "Author New")

      books.search('title:Ne').ids.should == [1]
    end
  end
  
end