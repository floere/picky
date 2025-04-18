# encoding: utf-8

require 'spec_helper'

# This spec exists to prove that it is unnecessary
# to call allocations.uniq! when putting together results.
#
describe 'uniqueness of allocations' do
  context 'is already uniq' do
    let(:index) do
      index = Picky::Index.new :already_uniq do
        category :category1
        category :category2
        category :category3
      end

      thing = Struct.new(:id, :category1, :category2, :category3)
      index.add thing.new(1, 'text1', 'text2', 'text3')

      index
    end
    let(:try) do
      Picky::Search.new index do
        max_allocations 100
      end
    end

    # Picky finds three categories.
    #
    it { try.search('text*').ids.should == [1, 1, 1] }

    # Picky finds 9 possible allocations.
    #
    it { try.search('text* text*').ids.should == [1, 1, 1] * 3 }

    # Picky finds 27 possible allocations.
    #
    it { try.search('text* text* text*', 100).ids.should == [1, 1, 1] * 3 * 3 }
  end
end
