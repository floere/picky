require 'spec_helper'

describe Picky::Bundle do

  before(:each) do
    @index        = Picky::Index.new :some_index
    @category     = Picky::Category.new :some_category, @index

    @weights      = double :weights, saved?: true
    @partial      = double :partial, saved?: true
    @similarity   = double :similarity, saved?: true
    @bundle       = described_class.new :some_name, @category, @weights, @partial, @similarity
  end

  describe 'to_s' do
    it 'does something' do
      @bundle.to_s.should == "Picky::Bundle(some_index:some_category:some_name)"
    end
  end

  describe 'clear_index' do
    before(:each) do
      @bundle.instance_variable_set :@inverted, { a: [] }
    end
    it 'has not cleared the inverted index' do
      @bundle.inverted.should == { a: [] }
    end
    it 'clears the inverted index' do
      @bundle.clear_inverted

      @bundle.inverted.should be_empty
    end
  end
  describe 'clear_weights' do
    before(:each) do
      @bundle.instance_variable_set :@weights, { a: 1.0 }
    end
    it 'has not cleared the weights' do
      @bundle.weights.should == { a: 1.0 }
    end
    it 'clears the weights' do
      @bundle.clear_weights

      @bundle.weights.should be_empty
    end
  end
  describe 'clear_similarity' do
    before(:each) do
      @bundle.instance_variable_set :@similarity, { a: :aa }
    end
    it 'has not cleared the similarity index' do
      @bundle.similarity.should == { a: :aa }
    end
    it 'clears the similarity index' do
      @bundle.clear_similarity

      @bundle.similarity.should be_empty
    end
  end
  describe 'clear_configuration' do
    before(:each) do
      @bundle.instance_variable_set :@configuration, { a: 'value' }
    end
    it 'has not cleared the similarity index' do
      @bundle.configuration.should == { a: 'value' }
    end
    it 'clears the similarity index' do
      @bundle.clear_configuration

      @bundle.configuration.should be_empty
    end
  end

  describe 'identifier' do
    it 'should return a specific identifier' do
      @bundle.identifier.should == :'some_index:some_category:some_name'
    end
  end

  describe 'ids' do
    before(:each) do
      @bundle.instance_variable_set :@inverted, { existing: :some_ids }
    end
    it 'should return an empty array if not found' do
      @bundle.ids(:non_existing).should == []
    end
    it 'should return the ids if found' do
      @bundle.ids(:existing).should == :some_ids
    end
  end

  describe 'weight' do
    before(:each) do
      @bundle.instance_variable_set :@weights, { existing: :specific }
    end
    it 'should return nil' do
      @bundle.weight(:non_existing).should == nil
    end
    it 'should return the weight for the text' do
      @bundle.weight(:existing).should == :specific
    end
  end

  describe 'load' do
    before(:each) do
      @bundle.dump # Create an index first.
    end
    it 'should trigger loads' do
      @bundle.should_receive(:load_inverted).once.with :something
      @bundle.should_receive(:load_weights).once.with :something
      @bundle.should_receive(:load_similarity).once.with :something
      @bundle.should_receive(:load_configuration).once.with no_args

      @bundle.load :something
    end
  end
  describe "loading indexes" do
    before(:each) do
      @bundle.stub :timed_exclaim
    end
    describe "load_index" do
      it "uses the right file" do
        MultiJson.stub :decode

        File.should_receive(:open).once.with 'spec/temp/index/test/some_index/some_category_some_name_inverted.memory.json', 'r'

        @bundle.load_inverted :anything
      end
    end
    describe "load_weights" do
      it "uses the right file" do
        MultiJson.stub :decode

        File.should_receive(:open).once.with 'spec/temp/index/test/some_index/some_category_some_name_weights.memory.json', 'r'

        @bundle.load_weights :anything
      end
    end
    describe "load_similarity" do
      it "uses the right file" do
        Marshal.stub :load

        File.should_receive(:open).once.with 'spec/temp/index/test/some_index/some_category_some_name_similarity.memory.dump', 'r:binary'

        @bundle.load_similarity :anything
      end
    end
    describe "load_configuration" do
      it "uses the right file" do
        MultiJson.stub :decode

        File.should_receive(:open).once.with 'spec/temp/index/test/some_index/some_category_some_name_configuration.memory.json', 'r'

        @bundle.load_configuration
      end
    end
  end

  describe 'initialization' do
    before(:each) do
      @index    = Picky::Index.new :some_index
      @category = Picky::Category.new :some_category, @index

      @weights = double :weights, saved?: true
      @partial = double :partial, saved?: true
      @bundle = described_class.new :some_name, @category, @weights, @partial, :similarity
    end
    it 'should initialize the index correctly' do
      @bundle.backend_inverted.should be_kind_of(Picky::Backends::Memory::JSON)
    end
    it 'should initialize the weights index correctly' do
      @bundle.backend_weights.should be_kind_of(Picky::Backends::Memory::JSON)
    end
    it 'should initialize the similarity index correctly' do
      @bundle.backend_similarity.should be_kind_of(Picky::Backends::Memory::Marshal)
    end
    it 'should initialize the configuration correctly' do
      @bundle.backend_configuration.should be_kind_of(Picky::Backends::Memory::JSON)
    end
    it 'should initialize the similarity strategy correctly' do
      @bundle.similarity_strategy.should == :similarity
    end
  end

end