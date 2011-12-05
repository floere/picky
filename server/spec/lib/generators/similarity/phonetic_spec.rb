# encoding: utf-8
#
require 'spec_helper'

describe Picky::Generators::Similarity::Phonetic do

  it 'raises if you try to use Phonetic directly' do
    expect {
      described_class.new
    }.to raise_error("In Picky 2.0+, the Similarity::Phonetic has been renamed to Similarity::DoubleMetaphone. Please use that one. Thanks!")
  end

  describe 'sort!' do
    let(:phonetic) { described_class.allocate }
    it 'sorts correctly' do
      phonetic.instance_variable_set :@amount, 2

      ary = [:a, :b, :c]
      phonetic.sort ary, :b
      ary.should == [:b, :a]
    end
    it 'sorts correctly' do
      phonetic.instance_variable_set :@amount, 2

      ary = [:aaa, :aa, :aaaa]
      phonetic.sort ary, :aaa
      ary.should == [:aaa, :aa]
    end
    it 'sorts correctly' do
      phonetic.instance_variable_set :@amount, 3

      ary = [:aaa, :aa, :aaaa]
      phonetic.sort ary, :aaa
      ary.should == [:aaa, :aa, :aaaa]
    end
    it 'sorts correctly' do
      phonetic.instance_variable_set :@amount, 3

      ary = [:aaaaa, :aa, :aaaa]
      phonetic.sort ary, :aaa
      ary.should == [:aaaa, :aa, :aaaaa]
    end
    it 'sorts correctly' do
      phonetic.instance_variable_set :@amount, 3

      ary = [:aaaaa, :aa]
      phonetic.sort ary, :aaa
      ary.should == [:aa, :aaaaa]
    end
    it 'sorts correctly' do
      phonetic.instance_variable_set :@amount, 3

      ary = [:aaa]
      phonetic.sort ary, :aaa
      ary.should == [:aaa]
    end
  end

end