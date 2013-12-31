require 'spec_helper'

describe Picky::Category do

  before(:each) do
    @index  = Picky::Index.new :some_index
    @source = double :some_given_source, :each => nil
  end
  let(:category) { described_class.new(:some_category, @index, :source => @source).tap { |c| c.stub :timed_exclaim } }

  context "unit specs" do
    let(:exact) { category.exact }
    let(:partial) { category.partial }

    describe 'clear' do
      it 'forwards to both bundles' do
        exact.should_receive(:clear).once.with()
        partial.should_receive(:clear).once.with()

        category.clear
      end
    end

    describe 'dump' do
      before(:each) do
        exact.stub :dump
        partial.stub :dump
      end
      it 'should dump the exact index' do
        exact.should_receive(:dump).once.with

        category.dump
      end
      it 'should dump the partial index' do
        partial.should_receive(:dump).once.with

        category.dump
      end
    end

    describe 'cache' do
      it 'should call multiple methods in order' do
        category.should_receive(:empty).once.with().ordered
        category.should_receive(:retrieve).once.with().ordered
        category.should_receive(:dump).once.with().ordered

        category.cache
      end
    end

    describe 'retrieve' do
      it 'call the right thing' do
        prepared = double :prepared
        prepared.should_receive(:retrieve).any_number_of_times
                                          .and_yield(1, :some_token)
                                          .and_yield(2, :some_token)
                                          .and_yield(3, :some_token)
                                          .and_yield(4, :some_token)
                                          .and_yield(5, :some_token)
        category.stub :prepared => prepared

        category.should_receive(:add_tokenized_token).once.with(1, :some_token, :<<, nil)
        category.should_receive(:add_tokenized_token).once.with(2, :some_token, :<<, nil)
        category.should_receive(:add_tokenized_token).once.with(3, :some_token, :<<, nil)
        category.should_receive(:add_tokenized_token).once.with(4, :some_token, :<<, nil)
        category.should_receive(:add_tokenized_token).once.with(5, :some_token, :<<, nil)

        category.retrieve
      end
    end

    describe 'key_format' do
      context 'category has its own key_format' do
        before(:each) do
          category.instance_variable_set :@key_format, :other_key_format
        end
        it 'returns that key_format' do
          category.key_format.should == :other_key_format
        end
      end
      context 'category does not have its own key format' do
        before(:each) do
          category.instance_variable_set :@key_format, nil
        end
        context 'it has an index' do
          before(:each) do
            category.instance_variable_set :@index, stub(:index, :key_format => :yet_another_key_format)
          end
          it 'returns that key_format' do
            category.key_format.should == :yet_another_key_format
          end
        end
      end
    end

    describe 'source' do
      context 'with explicit source' do
        let(:category) { described_class.new(:some_category, @index, :source => [1]) }
        it 'returns the right source' do
          category.source.should == [1]
        end
      end
      context 'without explicit source' do
        let(:category) { described_class.new(:some_category, @index.tap{ |index| index.stub :source => :index_source }) }
        it 'returns the right source' do
          category.source.should == :index_source
        end
      end
    end

    describe "index" do
      before(:each) do
        @indexer = double :indexer, :index => nil
        category.stub :indexer => @indexer
      end
      it "tells the indexer to index" do
        @indexer.should_receive(:prepare).once

        category.prepare
      end
    end
    describe "source" do
      context "without source" do
        it "has no problem with that" do
          lambda { described_class.new :some_name, @index }.should_not raise_error
        end
      end
    end
  end

end