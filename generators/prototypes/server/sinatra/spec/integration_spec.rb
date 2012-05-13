# coding: utf-8
#
require 'spec_helper'
require 'picky-client/spec'

describe 'Integration Tests' do

  before(:all) do
    Picky::Indexes.index
    Picky::Indexes.load
  end

  let(:books) { Picky::TestClient.new(BookSearch, :path => '/books') }

  # Testing a count of results.
  #
  it { books.search('a s').total.should == 57 }

  # Testing a specific order of result ids.
  #
  it { books.search('alan').ids.should == [449, 259, 307] }

  # Testing an order of result categories.
  #
  it { books.search('alan').should have_categories(['title'], ['author']) }
  it { books.search('alan p').should have_categories(['title', 'author'], ['author', 'title']) }

end