require 'spec_helper'
require 'ostruct'

describe 'Hint: no_dump' do
  ComicBook = Struct.new(:id, :title, :author)

  let(:index) do
    Picky::Index.new :no_dump do
      optimize :no_dump

      category :title
      category :author
    end
  end
  let(:try) { Picky::Search.new index }

  it 'can index and search' do
    index.replace ComicBook.new(2, 'Title', 'Author')

    try.search('title:title').ids.should == [2]
  end

  context 'dumping and loading' do
    it 'does not raise (as GoogleHashSparseRubyToRuby was removed)' do
      index.replace ComicBook.new(2, 'Title New', 'Author New')

      expect {
        index.dump
        index.load
        index.build_realtime_mapping
      }.to_not raise_error
    end
  end
end
