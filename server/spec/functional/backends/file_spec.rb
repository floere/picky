# encoding: utf-8
#
require 'spec_helper'

# Describes a Picky index that uses the File backend
# for data storage.
#
describe Picky::Backends::File do

  class Book
    attr_reader :id, :title, :author
    def initialize id, title, author
      @id, @title, @author = id, title, author
    end
  end

  attr_reader :data, :books

  let(:data) do
    Picky::Index.new(:books) do
      key_format :to_s # TODO Also make to_i work.
      source []
      category :title, partial: Picky::Partial::Postfix.new(from: 1)
      category :author, similarity: Picky::Generators::Similarity::DoubleMetaphone.new(3)
    end
  end
  let(:books) { Picky::Search.new data }

  its = ->(*) do
    it 'searching for it' do
      books.search('title').ids.should == ['1']
    end
    it 'searching for it using multiple words' do
      books.search('title author').ids.should == ['1']
    end
    it 'searching for it using partial' do
      books.search('tit').ids.should == ['1']
    end
    it 'searching for it using similarity' do
      books.search('aothor~').ids.should == ['1']
    end
    it 'handles removing' do
      data.remove 1

      books.search('title').ids.should == []
    end
    it 'handles removing with more than one entry' do
      data.add Book.new(2, 'title', 'author')

      books.search('title').ids.should == ['2', '1']

      data.remove '1'

      books.search('title').ids.should == ['2']
    end
    it 'handles removing with three entries' do
      data.add Book.new(2, 'title', 'author')
      data.add Book.new(3, 'title', 'author')

      books.search('title').ids.should == ['3', '2', '1']

      data.remove '1'

      books.search('title').ids.should == ['3', '2']
    end
    it 'handles replacing' do
      data.replace Book.new(1, 'toitle', 'oithor')

      books.search('title').ids.should == []
      books.search('toitle').ids.should == ['1']
    end
    it 'handles clearing' do
      data.clear

      books.search('title').ids.should == []
    end
    it 'handles dumping and loading' do
      data.dump
      data.load

      books.search('title').ids.should == ['1']
    end
  end

  context 'immediately indexing backend (no dump needed)' do
    before(:each) do
      data.backend described_class.new
      data.clear

      data.add Book.new(1, 'title', 'author')
    end

    instance_eval &its
  end

end