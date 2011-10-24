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
  
  let(:index) do
    Picky::Index.new(:test) do
      source []
      category :title
      category :author, similarity: Picky::Generators::Similarity::DoubleMetaphone.new(3)
    end
  end
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
    it 'handles more complex cases' do
      index.remove 1
      
      books.search('Titl').ids.should == []
      
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
    it 'handles more complex cases' do
      index.remove 1
      
      books.search('Titl').ids.should == []
      
      index.replace Book.new(1, "Title New", "Author New")

      books.search('title:Ne').ids.should == [1]
    end
  end
  
  context 'similarity' do
    it 'finds the first entry' do
      books.search('Authr~').ids.should == [1]
    end

    it 'allows removing something' do
      index.remove 1
    end
    it 'is not findable anymore after removing' do
      books.search('Authr~').ids.should == [1]

      index.remove 1

      books.search('Authr~').ids.should == []
    end

    it 'allows adding something' do
      index.add Book.new(2, "Title2", "Author2")
    end
    it 'is findable after adding' do
      books.search('Authr~').ids.should == [1]

      index.add Book.new(2, "Title New", "Author New")

      books.search('Authr~').ids.should == [2,1]
    end

    it 'allows replacing something' do
      index.replace Book.new(1, "Title New", "Author New")
    end
    it 'is findable after replacing' do
      books.search('Nuw~').ids.should == []

      index.replace Book.new(1, "Title New", "Author New")

      books.search('Nuw~').ids.should == [1, 1] # TODO FIXME Not really what I'd expect.
    end
    it 'handles more complex cases' do
      books.search('Now~').ids.should == []

      index.replace Book.new(1, "Title New", "Author New")

      books.search('author:Now~').ids.should == [1]
    end
    it 'handles more complex cases' do
      index.remove 1
      
      books.search('Athr~').ids.should == []
      
      index.replace Book.new(1, "Title New", "Author New")

      books.search('author:Athr~').ids.should == [1]
    end
    it 'handles more complex cases' do
      books.search('Athr~').ids.should == [1]
      
      index.replace Book.new(2, "Title New", "Author New")
      index.add Book.new(3, "TTL", "AUTHR")

      books.search('author:Athr~').ids.should == [2, 1, 3] # TODO Is that what I'd expect?
    end
  end
  
end