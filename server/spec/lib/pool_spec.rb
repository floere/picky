# encoding: utf-8

require 'spec_helper'

describe Picky::Pool do
  let(:pool_klass) do
    Class.new do
      extend Picky::Pool

      attr_reader :number

      def initialize(number)
        @number = number
      end
    end
  end
  let(:other) do
    Class.new do
      extend Picky::Pool

      attr_reader :number

      def initialize(number)
        @number = number
      end
    end
  end

  context 'functional' do
    before(:each) do
      described_class.clear
      pool_klass.clear
      other.clear
    end
    it 'lets me get an instance' do
      pool_klass.new(1).should be_kind_of(pool_klass)
    end
    it 'does not create a new reference if it has free ones' do
      p1 = pool_klass.new 1
      pool_klass.new 2
      p1.release

      pool_klass.free_size.should == 1
    end
    it 'gives me the released reference if I try to new' do
      p1 = pool_klass.new 1
      pool_klass.new 2
      p1.release

      pool_klass.new(3).number.should == 3
    end
    it 'releases all PoolTests if called on PoolTest' do
      p1 = pool_klass.new 1
      pool_klass.new 2
      other.new 1
      other.new 2

      other.free_size.should == 0

      pool_klass.release_all

      pool_klass.new(3).should == p1
      other.free_size.should == 0
    end
    it 'releases all if called on Pool' do
      pool_klass.new 1
      pool_klass.new 2
      other.new 1
      other.new 2

      pool_klass.free_size.should == 0

      described_class.release_all

      pool_klass.free_size.should == 2
    end
  end
end
