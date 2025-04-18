# encoding: utf-8

require 'spec_helper'

# Describes a Picky index that uses the Redis backend
# for data storage.
#
describe Picky::Backends::Redis do
  class Book
    attr_reader :id, :title, :author

    def initialize(id, title, author)
      @id, @title, @author = id, title, author
    end
  end

  attr_reader :data, :books

  let(:data) do
    Picky::Index.new(:books) do
      source []
      category :title, partial: Picky::Partial::Postfix.new(from: 1)
      category :author, similarity: Picky::Generators::Similarity::DoubleMetaphone.new(3)
    end
  end
  let(:books) { Picky::Search.new data }

  its_to_s = ->(*) do
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

      books.search('title').ids.should

      data.remove '1'

      books.search('title').ids.should == ['2']
    end
    it 'handles removing with three entries' do
      data.add Book.new(2, 'title', 'author')
      data.add Book.new(3, 'title', 'author')

      books.search('title').ids.should

      data.remove '1'

      books.search('title').ids.should == %w[3 2]
    end
    it 'handles replacing' do
      data.replace Book.new(1, 'toitle', 'oithor')

      books.search('title').ids.should
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

  its_to_i = ->(*) do
    it 'searching for it' do
      books.search('title').ids.should == [1]
    end
    it 'searching for it using multiple words' do
      books.search('title author').ids.should == [1]
    end
    it 'searching for it using partial' do
      books.search('tit').ids.should == [1]
    end
    it 'searching for it using similarity' do
      books.search('aothor~').ids.should == [1]
    end
    it 'handles removing' do
      data.remove 1

      books.search('title').ids.should == []
    end
    it 'handles removing with more than one entry' do
      data.add Book.new(2, 'title', 'author')

      books.search('title').ids.should

      data.remove 1

      books.search('title').ids.should == [2]
    end
    it 'handles removing with three entries' do
      data.add Book.new(2, 'title', 'author')
      data.add Book.new(3, 'title', 'author')

      books.search('title').ids.should

      data.remove 1

      books.search('title').ids.should == [3, 2]
    end
    it 'handles replacing' do
      data.replace Book.new(1, 'toitle', 'oithor')

      books.search('title').ids.should
      books.search('toitle').ids.should == [1]
    end
    it 'handles clearing' do
      data.clear

      books.search('title').ids.should == []
    end
    # TODO
    #
    # it 'handles dumping and loading' do
    #   data.dump
    #   data.load
    #
    #   books.search('title').ids.should == [1]
    # end
  end

  context 'to_s key format' do
    context 'immediately indexing backend (no dump needed)' do
      before(:each) do
        data.key_format :to_s
        data.backend described_class.new
        data.clear

        data.add Book.new(1, 'title', 'author')
      end

      instance_eval(&its_to_s)
    end
  end
  context 'to_i key format' do
    context 'immediately indexing backend (no dump needed)' do
      before(:each) do
        data.key_format :to_i
        data.backend described_class.new
        data.clear

        data.add Book.new(1, 'title', 'author')
      end

      instance_eval(&its_to_i)
    end
  end

  describe 'special case' do
    before(:each) do
      data.key_format :to_i
      data.backend described_class.new
      data.clear
    end
    it 'handles direct manipulation and []= correctly' do
      data.each_category do |category|
        category.exact.dump
        category.exact.load
        category.exact.inverted['test'] = [1, 2, 3]
        category.exact.inverted['test'] = [4, 5, 6]
        category.exact.inverted['test'].should
        category.exact.inverted['test'].delete '5'
        category.exact.inverted['test'].should
        category.exact.inverted['test'].unshift '3'
        category.exact.inverted['test'].should == %w[3 4 6]
      end
    end
  end
end
