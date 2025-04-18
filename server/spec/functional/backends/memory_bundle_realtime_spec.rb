require 'spec_helper'

describe Picky::Bundle do
  before(:each) do
    @index        = Picky::Index.new :some_index
    @category     = Picky::Category.new :some_category, @index

    @weights      = Picky::Generators::Weights::Default
    @partial      = Picky::Generators::Partial::Default
    @similarity   = Picky::Generators::Similarity::DoubleMetaphone.new 3
    @bundle       = described_class.new :some_name,
                                        @category,
                                        @weights,
                                        @partial,
                                        @similarity,
                                        backend: Picky::Backends::Memory.new
  end

  it 'is by default Hash-like' do
    @bundle.realtime.should respond_to(:to_hash)
  end
  it 'is by default Hash-like' do
    @bundle.inverted.should respond_to(:to_hash)
  end
  it 'is by default Hash-like' do
    @bundle.weights.should respond_to(:to_hash)
  end
  it 'is by default Hash-like' do
    @bundle.similarity.should respond_to(:to_hash)
  end

  context 'strings' do
    describe 'combined' do
      it 'works correctly' do
        @bundle.add 1, 'title'
        @bundle.add 2, 'title'

        @bundle.realtime[1].should
        @bundle.realtime[2].should
        @bundle.inverted['title'].should
        @bundle.weights['title'].should
        @bundle.similarity['TTL'].should == ['title']
      end
      it 'works correctly' do
        @bundle.add 1, 'title'
        @bundle.add 2, 'title'
        @bundle.remove 1
        @bundle.remove 2

        @bundle.realtime[1].should
        @bundle.realtime[2].should
        @bundle.inverted['title'].should
        @bundle.weights['title'].should
        @bundle.similarity['TTL'].should == nil
      end
      it 'works correctly' do
        @bundle.add 1, 'title'
        @bundle.add 1, 'other'
        @bundle.add 1, 'whatever'
        @bundle.remove 1

        @bundle.realtime[1].should
        @bundle.realtime[2].should
        @bundle.inverted['title'].should
        @bundle.weights['title'].should
        @bundle.similarity['TTL'].should == nil
      end
      it 'works correctly' do
        @bundle.add 1, 'title'
        @bundle.add 2, 'thing'
        @bundle.add 1, 'other'
        @bundle.remove 1

        @bundle.realtime[1].should
        @bundle.realtime[2].should
        @bundle.inverted['thing'].should
        @bundle.weights['thing'].should
        @bundle.similarity['0NK'].should == ['thing']
      end
      it 'works correctly' do
        @bundle.add 1, 'title'
        @bundle.add 1, 'title'

        @bundle.realtime[1].should
        @bundle.inverted['title'].should
        @bundle.weights['title'].should
        @bundle.similarity['TTL'].should == ['title']
      end
      it 'works correctly' do
        @bundle.add 1, 'title'
        @bundle.remove 1
        @bundle.remove 1

        @bundle.realtime[1].should
        @bundle.inverted['title'].should
        @bundle.weights['title'].should
        @bundle.similarity['TTL'].should == nil
      end
    end

    describe 'add' do
      it 'works correctly' do
        @bundle.add 1, 'title'

        @bundle.realtime[1].should

        @bundle.add 2, 'other'

        @bundle.realtime[1].should
        @bundle.realtime[2].should

        @bundle.add 1, 'thing'

        @bundle.realtime[1].should
        @bundle.realtime[2].should == ['other']
      end
      it 'works correctly' do
        @bundle.add 1, 'title'

        @bundle.weights['title'].should
        @bundle.inverted['title'].should
        @bundle.similarity['TTL'].should == ['title']
      end
    end
  end

  context 'symbols' do
    describe 'combined' do
      it 'works correctly' do
        @bundle.add 1, :title
        @bundle.add 2, :title

        @bundle.realtime.should
        @bundle.inverted.should
        @bundle.weights.should
        @bundle.similarity.should

        @bundle.realtime[1].should
        @bundle.realtime[2].should
        @bundle.inverted[:title].should
        @bundle.weights[:title].should
        @bundle.similarity[:TTL].should == [:title]
      end
      it 'works correctly' do
        @bundle.add 1, :title
        @bundle.add 2, :title
        @bundle.remove 1
        @bundle.remove 2

        @bundle.realtime[1].should
        @bundle.realtime[2].should
        @bundle.inverted[:title].should
        @bundle.weights[:title].should
        @bundle.similarity[:TTL].should == nil
      end
      it 'works correctly' do
        @bundle.add 1, :title
        @bundle.add 1, :other
        @bundle.add 1, :whatever
        @bundle.remove 1

        @bundle.realtime[1].should
        @bundle.inverted[:title].should
        @bundle.weights[:title].should
        @bundle.similarity[:TTL].should == nil
      end
      it 'works correctly' do
        @bundle.add 1, :title
        @bundle.add 2, :thing
        @bundle.add 1, :other
        @bundle.remove 1

        @bundle.realtime[1].should
        @bundle.realtime[2].should
        @bundle.inverted[:thing].should
        @bundle.weights[:thing].should
        @bundle.similarity[:'0NK'].should == [:thing]
      end
      it 'works correctly' do
        @bundle.add 1, :title
        @bundle.add 1, :title

        @bundle.realtime[1].should
        @bundle.inverted[:title].should
        @bundle.weights[:title].should
        @bundle.similarity[:TTL].should == [:title]
      end
      it 'works correctly' do
        @bundle.add 1, :title
        @bundle.remove 1
        @bundle.remove 1

        @bundle.realtime[1].should
        @bundle.inverted[:title].should
        @bundle.weights[:title].should
        @bundle.similarity[:TTL].should == nil
      end
    end

    describe 'add' do
      it 'works correctly' do
        @bundle.add 1, :title

        @bundle.realtime[1].should

        @bundle.add 2, :other

        @bundle.realtime[1].should
        @bundle.realtime[2].should

        @bundle.add 1, :thing

        @bundle.realtime[1].should
        @bundle.realtime[2].should == [:other]
      end
      it 'works correctly' do
        @bundle.add 1, :title

        @bundle.weights[:title].should
        @bundle.inverted[:title].should
        @bundle.similarity[:TTL].should == [:title]
      end
    end
  end
end
