require 'spec_helper'

describe Internals::Index::Redis do

  context 'indexing' do
    let(:category) do
      index    = stub :index, :name => :some_index
      category = Internals::Indexing::Category.new :some_category, index
    end
    let(:redis) { described_class.new :some_name, category }

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
        index = stub :index
        redis.stub! :index => index

        index.should_receive(:collection).once.with :some_sym

        redis.ids :some_sym
      end
      it 'returns the value' do
        index = stub :index
        redis.stub! :index => index

        index.should_receive(:collection).any_number_of_times.and_return [1,2,3]

        redis.ids(:any).should == [1,2,3]
      end
    end
  end
  
  context 'indexed' do
    let(:category) do
      index    = stub :index, :name => :some_index
      category = Internals::Indexed::Category.new :some_category, index
    end
    let(:redis) { described_class.new :some_name, category }

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
        index = stub :index
        redis.stub! :index => index

        index.should_receive(:collection).once.with :some_sym

        redis.ids :some_sym
      end
      it 'returns the value' do
        index = stub :index
        redis.stub! :index => index

        index.should_receive(:collection).any_number_of_times.and_return [1,2,3]

        redis.ids(:any).should == [1,2,3]
      end
    end
  end

end