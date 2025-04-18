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

        @bundle.realtime[1].should == ['title']
        @bundle.realtime[2].should == ['title']
        @bundle.inverted['title'].should == [2,1]
        @bundle.weights['title'].should == 0.693
        @bundle.similarity['TTL'].should == ['title']
      end
      it 'works correctly' do
        @bundle.add 1, 'title'
        @bundle.add 2, 'title'
        @bundle.remove 1
        @bundle.remove 2

        @bundle.realtime[1].should == nil
        @bundle.realtime[2].should == nil
        @bundle.inverted['title'].should == nil
        @bundle.weights['title'].should == nil
        @bundle.similarity['TTL'].should == nil
      end
      it 'works correctly' do
        @bundle.add 1, 'title'
        @bundle.add 1, 'other'
        @bundle.add 1, 'whatever'
        @bundle.remove 1

        @bundle.realtime[1].should == nil
        @bundle.realtime[2].should == nil
        @bundle.inverted['title'].should == nil
        @bundle.weights['title'].should == nil
        @bundle.similarity['TTL'].should == nil
      end
      it 'works correctly' do
        @bundle.add 1, 'title'
        @bundle.add 2, 'thing'
        @bundle.add 1, 'other'
        @bundle.remove 1

        @bundle.realtime[1].should == nil
        @bundle.realtime[2].should == ['thing']
        @bundle.inverted['thing'].should == [2]
        @bundle.weights['thing'].should == 0.0
        @bundle.similarity['0NK'].should == ['thing']
      end
      it 'works correctly' do
        @bundle.add 1, 'title'
        @bundle.add 1, 'title'

        @bundle.realtime[1].should == ['title']
        @bundle.inverted['title'].should == [1]
        @bundle.weights['title'].should == 0.0
        @bundle.similarity['TTL'].should == ['title']
      end
      it 'works correctly' do
        @bundle.add 1, 'title'
        @bundle.remove 1
        @bundle.remove 1

        @bundle.realtime[1].should == nil
        @bundle.inverted['title'].should == nil
        @bundle.weights['title'].should == nil
        @bundle.similarity['TTL'].should == nil
      end
    end

    describe 'add' do
      it 'works correctly' do
        @bundle.add 1, 'title'

        @bundle.realtime[1].should == ['title']

        @bundle.add 2, 'other'

        @bundle.realtime[1].should == ['title']
        @bundle.realtime[2].should == ['other']

        @bundle.add 1, 'thing'

        @bundle.realtime[1].should == %w[title thing]
        @bundle.realtime[2].should == ['other']
      end
      it 'works correctly' do
        @bundle.add 1, 'title'

        @bundle.weights['title'].should == 0.0
        @bundle.inverted['title'].should == [1]
        @bundle.similarity['TTL'].should == ['title']
      end
    end
  end

  context 'symbols' do
    describe 'combined' do
      it 'works correctly' do
        @bundle.add 1, :title
        @bundle.add 2, :title

        @bundle.realtime.should == { 1 => [:title], 2 => [:title] }
        @bundle.inverted.should == { title: [2,1] }
        @bundle.weights.should == { title: 0.693 }
        @bundle.similarity.should == { TTL: [:title] }

        @bundle.realtime[1].should == [:title]
        @bundle.realtime[2].should == [:title]
        @bundle.inverted[:title].should == [2,1]
        @bundle.weights[:title].should == 0.693
        @bundle.similarity[:TTL].should == [:title]
      end
      it 'works correctly' do
        @bundle.add 1, :title
        @bundle.add 2, :title
        @bundle.remove 1
        @bundle.remove 2

        @bundle.realtime[1].should == nil
        @bundle.realtime[2].should == nil
        @bundle.inverted[:title].should == nil
        @bundle.weights[:title].should == nil
        @bundle.similarity[:TTL].should == nil
      end
      it 'works correctly' do
        @bundle.add 1, :title
        @bundle.add 1, :other
        @bundle.add 1, :whatever
        @bundle.remove 1

        @bundle.realtime[1].should == nil
        @bundle.inverted[:title].should == nil
        @bundle.weights[:title].should == nil
        @bundle.similarity[:TTL].should == nil
      end
      it 'works correctly' do
        @bundle.add 1, :title
        @bundle.add 2, :thing
        @bundle.add 1, :other
        @bundle.remove 1

        @bundle.realtime[1].should == nil
        @bundle.realtime[2].should == [:thing]
        @bundle.inverted[:thing].should == [2]
        @bundle.weights[:thing].should == 0.0
        @bundle.similarity[:'0NK'].should == [:thing]
      end
      it 'works correctly' do
        @bundle.add 1, :title
        @bundle.add 1, :title

        @bundle.realtime[1].should == [:title]
        @bundle.inverted[:title].should == [1]
        @bundle.weights[:title].should == 0.0
        @bundle.similarity[:'TTL'].should == [:title]
      end
      it 'works correctly' do
        @bundle.add 1, :title
        @bundle.remove 1
        @bundle.remove 1

        @bundle.realtime[1].should == nil
        @bundle.inverted[:title].should == nil
        @bundle.weights[:title].should == nil
        @bundle.similarity[:TTL].should == nil
      end
    end

    describe 'add' do
      it 'works correctly' do
        @bundle.add 1, :title

        @bundle.realtime[1].should == [:title]

        @bundle.add 2, :other

        @bundle.realtime[1].should == [:title]
        @bundle.realtime[2].should == [:other]

        @bundle.add 1, :thing

        @bundle.realtime[1].should == [:title, :thing]
        @bundle.realtime[2].should == [:other]
      end
      it 'works correctly' do
        @bundle.add 1, :title

        @bundle.weights[:title].should == 0.0
        @bundle.inverted[:title].should == [1]
        @bundle.similarity[:TTL].should == [:title]
      end
    end
  end

end
