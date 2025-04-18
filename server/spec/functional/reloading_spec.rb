# encoding: utf-8
#
require 'spec_helper'

describe 'Realtime Indexing' do

  ReloadingBook = Struct.new(:id, :title, :author)

  context 'default index' do
    let(:index) do
      Picky::Index.new(:books) do
        category :title
        category :author, similarity: Picky::Generators::Similarity::DoubleMetaphone.new(3)
      end
    end
    let(:books) { Picky::Search.new index }

    before(:each) do
      index.add ReloadingBook.new(1, 'Title', 'Author')
    end

    context 'dumping and loading' do
      it "doesn't find books anymore after dumping and loading and updating" do
        index.replace ReloadingBook.new(2, 'Title New', 'Author New')

        books.search('title').ids.should == [2, 1]

        index.dump
        index.load
        index.build_realtime_mapping

        index.replace ReloadingBook.new(2, 'Blah New', 'Author New')

        books.search('title').ids.should == [1]
      end
    end
  end

end
