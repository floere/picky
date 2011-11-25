# encoding: utf-8
#
require 'spec_helper'

# Describes a Picky index that uses the SQLite backend
# for data storage.
#
describe "SQLite" do

  class Book
    attr_reader :id, :title, :author
    def initialize id, title, author
      @id, @title, @author = id, title, author
    end
  end

  let(:data) do
    Picky::Index.new(:books) do
      source []
      category :title
      category :author, similarity: Picky::Generators::Similarity::DoubleMetaphone.new(3)
    end
  end
  let(:books) { Picky::Search.new data }

  its = ->(*) do
    it 'searching for it' do
      books.search('title').ids.should == [1]
    end
    it 'handles removing' do
      data.remove 1

      books.search('title').ids.should == []
    end
    it 'handles removing with more than one entry' do
      data.add Book.new(2, 'newtitle', 'newauthor')

      books.search('title').ids.should == [2, 1]

      data.remove 1

      books.search('title').ids.should == [2]
    end
    it 'handles replacing' do
      data.replace Book.new(1, 'toitle', 'oithor')

      books.search('title').ids.should == []
      books.search('toitle').ids.should == [1]
    end
    it 'handles clearing' do
      data.clear

      books.search('title').ids.should == []
    end
    it 'handles dumping and loading' do
      data.dump
      data.load

      books.search('title').ids.should == [1]
    end
  end

  context 'default backend (dump needed)' do
    before(:each) do
      data.backend Picky::Backends::SQLite.new

      data.add Book.new(1, 'title', 'author')
    end
    instance_eval &its
  end

  context 'immediately indexing backend (no dump needed)' do
    before(:each) do
      data.backend Picky::Backends::SQLite.new(self_indexed: true)
      data.clear
      data.add Book.new(1, 'title', 'author')
    end
    instance_eval &its
  end

end