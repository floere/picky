require 'spec_helper'

describe Picky::Backend::Redis do

  context 'indexing' do
    let(:category) do
      index    = stub :index,
                      :name => :some_index,
                      :indexing_bundle_class => Picky::Indexing::Bundle::Memory,
                      :indexed_bundle_class  => Picky::Indexed::Bundle::Memory,
                      :identifier => :some_index_identifier
      Picky::Category.new :some_category, index
    end
    let(:bundle) { Picky::Indexing::Bundle::Memory.new :some_bundle, category, nil, nil, nil }
    let(:redis) { described_class.new bundle }

    describe 'setting' do
      it 'delegates to the configuration' do
        configuration = stub :configuration
        redis.stub! :configuration => configuration

        configuration.should_receive(:member).once.with :some_sym

        redis.setting :some_sym
      end
      it 'returns the value' do
        configuration = stub :configuration
        redis.stub! :configuration => configuration

        configuration.should_receive(:member).any_number_of_times.and_return "some config"

        redis.setting(:any).should == "some config"
      end
    end
    describe 'weight' do
      it 'delegates to the weights' do
        weights = stub :weights
        redis.stub! :weights => weights

        weights.should_receive(:member).once.with :some_sym

        redis.weight :some_sym
      end
      it 'returns a floated value' do
        weights = stub :weights
        redis.stub! :weights => weights

        weights.should_receive(:member).any_number_of_times.and_return "1.0"

        redis.weight(:any).should == 1.0
      end
      it 'returns a floated value' do
        weights = stub :weights
        redis.stub! :weights => weights

        weights.should_receive(:member).any_number_of_times.and_return 1

        redis.weight(:any).should == 1.0
      end
    end
    describe 'ids' do
      it 'delegates to the index' do
        inverted = stub :inverted
        redis.stub! :inverted => inverted

        inverted.should_receive(:collection).once.with :some_sym

        redis.ids :some_sym
      end
      it 'returns the value' do
        inverted = stub :inverted
        redis.stub! :inverted => inverted

        inverted.should_receive(:collection).any_number_of_times.and_return [1,2,3]

        redis.ids(:any).should == [1,2,3]
      end
    end
  end
  
  context 'indexed' do
    let(:category) do
      index = stub :index,
                   :name => :some_index,
                   :indexing_bundle_class => Picky::Indexing::Bundle::Memory,
                   :indexed_bundle_class  => Picky::Indexed::Bundle::Memory,
                   :identifier => :some_index_identifier
      Picky::Category.new :some_category, index
    end
    let(:bundle) { Picky::Indexing::Bundle::Memory.new :some_bundle, category, nil, nil, nil }
    let(:redis) { described_class.new bundle }

    describe 'setting' do
      it 'delegates to the configuration' do
        configuration = stub :configuration
        redis.stub! :configuration => configuration

        configuration.should_receive(:member).once.with :some_sym

        redis.setting :some_sym
      end
      it 'returns the value' do
        configuration = stub :configuration
        redis.stub! :configuration => configuration

        configuration.should_receive(:member).any_number_of_times.and_return "some config"

        redis.setting(:any).should == "some config"
      end
    end
    describe 'weight' do
      it 'delegates to the weights' do
        weights = stub :weights
        redis.stub! :weights => weights

        weights.should_receive(:member).once.with :some_sym

        redis.weight :some_sym
      end
      it 'returns a floated value' do
        weights = stub :weights
        redis.stub! :weights => weights

        weights.should_receive(:member).any_number_of_times.and_return "1.0"

        redis.weight(:any).should == 1.0
      end
      it 'returns a floated value' do
        weights = stub :weights
        redis.stub! :weights => weights

        weights.should_receive(:member).any_number_of_times.and_return 1

        redis.weight(:any).should == 1.0
      end
    end
    describe 'ids' do
      it 'delegates to the index' do
        inverted = stub :inverted
        redis.stub! :inverted => inverted

        inverted.should_receive(:collection).once.with :some_sym

        redis.ids :some_sym
      end
      it 'returns the value' do
        inverted = stub :inverted
        redis.stub! :inverted => inverted

        inverted.should_receive(:collection).any_number_of_times.and_return [1,2,3]

        redis.ids(:any).should == [1,2,3]
      end
    end
  end
  
  describe 'to_s' do
    it 'returns the right value' do
      category = stub :category,
                      :name => :some_category,
                      :identifier => "category_identifier",
                      :prepared_index_path => "prepared/index/path",
                      :index_directory => 'some/index/directory'
      bundle = Picky::Indexing::Bundle::Memory.new :some_bundle, category, nil, nil, nil
      
      described_class.new(bundle).to_s.should == "Picky::Backend::Redis(category_identifier:some_bundle)"
    end
  end

end