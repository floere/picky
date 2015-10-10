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
      
      it 'searching for it' do
        expected = Rust::Array.new
        books.search('title').ids.should == expected
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
        books.search('title').ids.should == expected
      end
    end
  end

end