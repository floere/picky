require 'spec_helper'

describe Picky::Index do
  let(:some_source) { double :source, each: nil, inspect: 'some_source' }

  context 'initializer' do
    it 'works' do
      the_source = some_source
      expect { described_class.new :some_index_name do source the_source end }.to_not raise_error
    end
    it 'fails correctly' do
      expect { described_class.new 0, some_source }.to raise_error
    end
    it 'fails correctly' do
      expect { described_class.new :some_index_name, some_source }.to raise_error
    end
    it 'does not fail' do
      expect { described_class.new :some_index_name do source [] end }.to_not raise_error
    end
    it 'does not fail' do
      expect { described_class.new :some_index_name do source { [] } end }.to_not raise_error
    end
    it 'evaluates the source every time' do
      expector = double :expector

      data = described_class.new :some_index_name do
        source do
          expector.call
        end
      end

      expector.should_receive(:call).twice.with no_args

      data.prepare
    end
    it 'registers with the indexes' do
      @api = described_class.allocate

      Picky::Indexes.should_receive(:register).once.with @api

      the_source = some_source
      @api.send :initialize, :some_index_name do
        source the_source
      end
    end
  end

  context 'unit' do
    let(:api) do
      the_source = some_source
      described_class.new :some_index_name do
        source the_source
      end
    end

    describe 'directory' do
      it 'is correct' do
        api.directory.should == 'spec/temp/index/test/some_index_name'
      end
    end

    describe 'geo_categories' do
      it 'forwards correctly' do
        api.should_receive(:ranged_category).once.with(:some_lat, 0.00898312, from: :some_lat_from)
        api.should_receive(:ranged_category).once.with(:some_lng, 0.01796624, from: :some_lng_from)

        api.geo_categories(:some_lat, :some_lng, 1, lat_from: :some_lat_from, lng_from: :some_lng_from)
      end
    end

    describe 'category' do
      context 'with block' do
        it 'returns the category' do
          expected = nil
          api.category(:some_name) { |category| expected = category }.should == expected
        end
        it 'takes a string' do
          -> { api.category('some_name') { |indexing, indexed| } }.should_not raise_error
        end
        it 'yields both the indexing category and the indexed category' do
          api.category(:some_name) do |category|
            category.should be_kind_of(Picky::Category)
          end
        end
        it 'yields the category which has the given name' do
          api.category(:some_name) do |category|
            category.name.should == :some_name
          end
        end
      end
      context 'without block' do
        it 'works' do
          -> { api.category(:some_name) }.should_not raise_error
        end
        it 'takes a string' do
          -> { api.category('some_name') }.should_not raise_error
        end
        it 'returns itself' do
          api.category(:some_name).should be_kind_of(Picky::Category)
        end
      end
    end

    describe '#to_stats' do
      let(:index) do
        the_source = some_source
        described_class.new :some_index_name do
          source the_source
          category :text1
          category :text2
          result_identifier :foobar
        end
      end

      it 'outputs the stats correctly' do
        index.to_stats.should == <<~EXPECTED
          some_index_name (Picky::Index):
            source:            some_source
            categories:        text1, text2
            result identifier: "foobar"
        EXPECTED
      end
    end

    describe '#to_tree_s' do
      let(:index) do
        some_source
        idx = described_class.new :some_index_name do
          source { [1, 2, 3] }
          category :text1
          category :text2
          result_identifier :foobar
        end
        idx.replace_from id: 1, text1: 'hello', text2: 'hoohoo'
        idx
      end

      it 'outputs the stats correctly' do
        index.to_tree_s.should == <<~EXPECTED
          Index(some_index_name)
            source: [1, 2, 3]
            result identifier: "foobar"
            categories:
              Category(text1)
                Bundle(exact)
                  Inverted(1)[Picky::Backends::Memory::JSON(spec/temp/index/test/some_index_name/text1_exact_inverted.memory.json)]
                  Weights (1)[Picky::Backends::Memory::JSON(spec/temp/index/test/some_index_name/text1_exact_weights.memory.json)]
                  Similari(0)[Picky::Backends::Memory::Marshal(spec/temp/index/test/some_index_name/text1_exact_similarity.memory.dump)]
                  Realtime(1)[Picky::Backends::Memory::JSON(spec/temp/index/test/some_index_name/text1_exact_realtime.memory.json)]
                  Configur(0)[Picky::Backends::Memory::JSON(spec/temp/index/test/some_index_name/text1_exact_configuration.memory.json)]
                Bundle(partial)
                  Inverted(3)[Picky::Backends::Memory::JSON(spec/temp/index/test/some_index_name/text1_partial_inverted.memory.json)]
                  Weights (3)[Picky::Backends::Memory::JSON(spec/temp/index/test/some_index_name/text1_partial_weights.memory.json)]
                  Similari(0)[Picky::Backends::Memory::Marshal(spec/temp/index/test/some_index_name/text1_partial_similarity.memory.dump)]
                  Realtime(1)[Picky::Backends::Memory::JSON(spec/temp/index/test/some_index_name/text1_partial_realtime.memory.json)]
                  Configur(0)[Picky::Backends::Memory::JSON(spec/temp/index/test/some_index_name/text1_partial_configuration.memory.json)]
              Category(text2)
                Bundle(exact)
                  Inverted(1)[Picky::Backends::Memory::JSON(spec/temp/index/test/some_index_name/text2_exact_inverted.memory.json)]
                  Weights (1)[Picky::Backends::Memory::JSON(spec/temp/index/test/some_index_name/text2_exact_weights.memory.json)]
                  Similari(0)[Picky::Backends::Memory::Marshal(spec/temp/index/test/some_index_name/text2_exact_similarity.memory.dump)]
                  Realtime(1)[Picky::Backends::Memory::JSON(spec/temp/index/test/some_index_name/text2_exact_realtime.memory.json)]
                  Configur(0)[Picky::Backends::Memory::JSON(spec/temp/index/test/some_index_name/text2_exact_configuration.memory.json)]
                Bundle(partial)
                  Inverted(3)[Picky::Backends::Memory::JSON(spec/temp/index/test/some_index_name/text2_partial_inverted.memory.json)]
                  Weights (3)[Picky::Backends::Memory::JSON(spec/temp/index/test/some_index_name/text2_partial_weights.memory.json)]
                  Similari(0)[Picky::Backends::Memory::Marshal(spec/temp/index/test/some_index_name/text2_partial_similarity.memory.dump)]
                  Realtime(1)[Picky::Backends::Memory::JSON(spec/temp/index/test/some_index_name/text2_partial_realtime.memory.json)]
                  Configur(0)[Picky::Backends::Memory::JSON(spec/temp/index/test/some_index_name/text2_partial_configuration.memory.json)]
        EXPECTED
      end
    end
  end
end
