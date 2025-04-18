# encoding: utf-8
#
require 'spec_helper'

# Describes how users see often used classes when calling #to_s on them.
#
describe 'to_s' do
  describe 'index' do
    it 'shows an index correctly' do
      index = Picky::Index.new :test do
      
      end
      index.to_s.should == 'Picky::Index(test, result_id: test)'
    end
    it 'shows an index correctly' do
      index = Picky::Index.new :test do
        category :alli
      end
      index.to_s.should == 'Picky::Index(test, result_id: test, categories: Picky::Categories(Picky::Category(test:alli)))'
    end
    it 'shows an index correctly' do
      index = Picky::Index.new :test do
        source { [1,2,3] }
        category :alli
      end
      index.to_s.should == 'Picky::Index(test, result_id: test, source: [1, 2, 3], categories: Picky::Categories(Picky::Category(test:alli)))'
    end
    it 'shows an index correctly' do
      index = Picky::Index.new :test do
        source { [1,2,3] }
        category :alli
        category :text
      end
      index.to_s.should == 'Picky::Index(test, result_id: test, source: [1, 2, 3], categories: Picky::Categories(Picky::Category(test:alli), Picky::Category(test:text)))'
    end
  end
  describe 'search' do
    it 'shows a search correctly' do
      search = Picky::Search.new
      search.to_s.should == 'Picky::Search(boosts: Picky::Query::Boosts({}))'
    end
    it 'shows a search correctly' do
      search = Picky::Search.new Picky::Index.new(:test)
      search.to_s.should == 'Picky::Search(test, boosts: Picky::Query::Boosts({}))'
    end
    it 'shows a search correctly' do
      search = Picky::Search.new Picky::Index.new(:test), Picky::Index.new(:test2)
      search.to_s.should == 'Picky::Search(test, test2, boosts: Picky::Query::Boosts({}))'
    end
    it 'shows a search correctly' do
      search = Picky::Search.new Picky::Index.new(:test), Picky::Index.new(:test2) do
        boost [:a] => +3
      end
      search.to_s.should == 'Picky::Search(test, test2, boosts: Picky::Query::Boosts({[:a]=>3}))'
    end
  end
end
