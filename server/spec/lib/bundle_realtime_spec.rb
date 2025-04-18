require 'spec_helper'

describe Picky::Bundle do

  before(:each) do
    @index        = Picky::Index.new :some_index
    @category     = Picky::Category.new :some_category, @index

    @weights      = Picky::Generators::Weights::Default
    @partial      = Picky::Generators::Partial::Default
    @similarity   = Picky::Generators::Similarity::DoubleMetaphone.new 3
    @bundle       = described_class.new :some_name, @category, @weights, @partial, @similarity
  end

  it 'is by default empty' do
    @bundle.realtime.should == {}
  end
  it 'is by default empty' do
    @bundle.weights.should == {}
  end
  it 'is by default empty' do
    @bundle.inverted.should == {}
  end
  it 'is by default empty' do
    @bundle.similarity.should == {}
  end

  context 'strings' do
    describe 'combined' do
      it 'works correctly' do
        @bundle.add 1, 'title'
        @bundle.add 2, 'title'

        @bundle.realtime.should == { 1 => ['title'], 2 => ['title'] }
        @bundle.inverted.should == { 'title' => [2, 1] }
        @bundle.weights.should == { 'title' => 0.693 }
        @bundle.similarity.should == { 'TTL' => ['title'] }
      end
      it 'works correctly' do
        @bundle.add 1, 'title'
        @bundle.add 2, 'title'
        @bundle.remove 1
        @bundle.remove 2

        @bundle.realtime.should == {}
        @bundle.weights.should == {}
        @bundle.inverted.should == {}
        @bundle.similarity.should == {}
      end
      it 'works correctly' do
        @bundle.add 1, 'title'
        @bundle.add 1, 'other'
        @bundle.add 1, 'whatever'
        @bundle.remove 1

        @bundle.realtime.should == {}
        @bundle.weights.should == {}
        @bundle.inverted.should == {}
        @bundle.similarity.should == {}
      end
      it 'works correctly' do
        @bundle.add 1, 'title'
        @bundle.add 2, 'thing'
        @bundle.add 1, 'other'
        @bundle.remove 1

        @bundle.realtime.should == { 2 => ['thing'] }
        @bundle.weights.should == { 'thing' => 0.0 }
        @bundle.inverted.should == { 'thing' => [2] }
        @bundle.similarity.should == { '0NK' => ['thing'] }
      end
      it 'works correctly' do
        @bundle.add 1, 'title'
        @bundle.add 1, 'title'

        @bundle.realtime.should == { 1 => ['title'] }
        @bundle.weights.should  == { 'title' => 0.0 }
        @bundle.inverted.should == { 'title' => [1] }
        @bundle.similarity.should  == { 'TTL' => ['title'] }
      end
      it 'works correctly' do
        @bundle.add 1, 'title'
        @bundle.remove 1
        @bundle.remove 1

        @bundle.realtime.should == {}
        @bundle.weights.should  == {}
        @bundle.inverted.should == {}
        @bundle.similarity.should == {}
      end
    end

    describe 'add' do
      it 'works correctly' do
        @bundle.add 1, 'title'

        @bundle.realtime.should == { 1 => ['title'] }

        @bundle.add 2, 'other'

        @bundle.realtime.should == { 1 => ['title'], 2 => ['other'] }

        @bundle.add 1, 'thing'

        @bundle.realtime.should == { 1 => %w[title thing], 2 => ['other'] }
      end
      it 'works correctly' do
        @bundle.add 1, 'title'

        @bundle.weights.should == { 'title' => 0.0 }
        @bundle.inverted.should == { 'title' => [1] }
        @bundle.similarity.should == { 'TTL' => ['title'] }
      end
    end
  end

  context 'symbols' do
    describe 'combined' do
      it 'works correctly' do
        @bundle.add 1, :title
        @bundle.add 2, :title

        @bundle.realtime.should == { 1 => [:title], 2 => [:title] }
        @bundle.inverted.should == { title: [2, 1] }
        @bundle.weights.should == { title: 0.693 }
        @bundle.similarity.should == { TTL: [:title] }
      end
      it 'works correctly' do
        @bundle.add 1, :title
        @bundle.add 2, :title
        @bundle.remove 1
        @bundle.remove 2

        @bundle.realtime.should == {}
        @bundle.weights.should == {}
        @bundle.inverted.should == {}
        @bundle.similarity.should == {}
      end
      it 'works correctly' do
        @bundle.add 1, :title
        @bundle.add 1, :other
        @bundle.add 1, :whatever
        @bundle.remove 1

        @bundle.realtime.should == {}
        @bundle.weights.should == {}
        @bundle.inverted.should == {}
        @bundle.similarity.should == {}
      end
      it 'works correctly' do
        @bundle.add 1, :title
        @bundle.add 2, :thing
        @bundle.add 1, :other
        @bundle.remove 1

        @bundle.realtime.should == { 2 => [:thing] }
        @bundle.weights.should == { thing: 0.0 }
        @bundle.inverted.should == { thing: [2] }
        @bundle.similarity.should == { "0NK": [:thing] }
      end
      it 'works correctly' do
        @bundle.add 1, :title
        @bundle.add 1, :title

        @bundle.realtime.should == { 1 => [:title] }
        @bundle.weights.should  == { title: 0.0 }
        @bundle.inverted.should == { title: [1] }
        @bundle.similarity.should  == { TTL: [:title] }
      end
      it 'works correctly' do
        @bundle.add 1, :title
        @bundle.remove 1
        @bundle.remove 1

        @bundle.realtime.should == {}
        @bundle.weights.should  == {}
        @bundle.inverted.should == {}
        @bundle.similarity.should == {}
      end
    end

    describe 'add' do
      it 'works correctly' do
        @bundle.add 1, :title

        @bundle.realtime.should == { 1 => [:title] }

        @bundle.add 2, :other

        @bundle.realtime.should == { 1 => [:title], 2 => [:other] }

        @bundle.add 1, :thing

        @bundle.realtime.should == { 1 => [:title, :thing], 2 => [:other] }
      end
      it 'works correctly' do
        @bundle.add 1, :title

        @bundle.weights.should == { title: 0.0 }
        @bundle.inverted.should == { title: [1] }
        @bundle.similarity.should == { TTL: [:title] }
      end
    end
  end

end
