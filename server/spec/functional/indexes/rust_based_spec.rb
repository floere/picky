# encoding: utf-8
#
require 'spec_helper'

require File.expand_path '../../../../../indexes/lib/picky-indexes', __FILE__

# Run this test with LD_LIBRARY_PATH=../indexes/lib/picky-indexes/ br spec/functional/indexes/rust_based_spec.rb for now.

describe Rust::Array do

  class Book
    attr_reader :id, :title, :author
    def initialize id, title, author
      @id, @title, @author = id, title, author
    end
  end

  attr_reader :data, :books

  context 'with an Integer based index' do
    let(:data) do
      Picky::Index.new(:books) do
        key_format :to_i
      
        backend Picky::Backends::Rust.new

        category :title
        category :author
      end
    end
    let(:books) { Picky::Search.new data }

    context 'with an empty index' do
      before(:each) do
        data.clear
      end
      
      it 'searching for it returns an empty Array (!)' do
        # No need to create a Rust::Array for that.
        books.search('title').ids.should == []
      end
    end

    context 'with 2 books' do
      before(:each) do
        data.clear
        data.add Book.new(1, 'title', 'author')
        data.add Book.new(2, 'another title', 'another author')
      end

      it 'searching for it' do
        expected = Rust::Array.new << 2 << 1
        # TODO Cannot be called twice!
        books.search('title').ids.should == expected
      end
      it 'can sort' do
        expected = Rust::Array.new << 1 << 2
        results = books.search('title')
        results.sort_by { |x| -x }
        results.ids.should == expected
      end
    end
    
    context 'with 1K books' do
      before(:each) do
        data.clear
        1000.times do |i|
          data.add Book.new(i, 'title', 'author')
        end
      end
      it 'searching for it' do
        expected = Rust::Array.new
        999.downto(980).each do |i|
          expected << i
        end
        books.search('title').ids.should == expected
      end
      it 'is reasonably fast' do
        performance_of do
          books.search('title')
        end.should < 0.002
        # Note: Native Ruby is < 0.0001 (20x faster)
      end
    end
  end

end