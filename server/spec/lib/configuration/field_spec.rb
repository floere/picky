require 'spec_helper'
describe Configuration::Field do
  
  context "unit specs" do
    describe "virtual?" do
      context "with virtual true" do
        before(:each) do
          @field = Configuration::Field.new :some_name, :some_tokenizer, :virtual => true
        end
        it "returns the right value" do
          @field.virtual?.should == true
        end
      end
      context "with virtual object" do
        before(:each) do
          @field = Configuration::Field.new :some_name, :some_tokenizer, :virtual => 123.6
        end
        it "returns the right value" do
          @field.virtual?.should == true
        end
      end
      context "with virtual nil" do
        before(:each) do
          @field = Configuration::Field.new :some_name, :virtual => nil
        end
        it "returns the right value" do
          @field.virtual?.should == false
        end
      end
      context "with virtual false" do
        before(:each) do
          @field = Configuration::Field.new :some_name, :virtual => false
        end
        it "returns the right value" do
          @field.virtual?.should == false
        end
      end
    end
    describe "tokenizer" do
      context "with specific tokenizer" do
        before(:each) do
          @field = Configuration::Field.new :some_name, Tokenizers::Default.new
          
          @field.type = :some_type
        end
        it "caches" do
          @field.tokenizer.should == @field.tokenizer
        end
        it "returns an instance" do
          @field.tokenizer.should be_kind_of(Tokenizers::Default)
        end
      end
    end
    describe "indexer" do
      context "with default indexer" do
        before(:each) do
          @field = Configuration::Field.new :some_name, :some_tokenizer
        end
        it "caches" do
          @field.indexer.should == @field.indexer
        end
      end
      context "with specific indexer" do
        before(:each) do
          @field = Configuration::Field.new :some_name, :indexer => Indexers::Default
          
          @field.type = :some_type
        end
        it "caches" do
          @field.indexer.should == @field.indexer
        end
        it "returns an instance" do
          @field.indexer.should be_kind_of(Indexers::Default)
        end
        it "creates a new instance of the right class" do
          Indexers::Default.should_receive(:new).once.with :some_type, @field
          
          @field.indexer
        end
      end
    end
    describe "cache" do
      before(:each) do
        @field = Configuration::Field.new :some_name, :some_tokenizer
        @field.stub! :prepare_cache_directory
        
        @generated = stub :generated, :generate_caches => nil
        @field.stub! :generate => @generated
      end
      it "prepares the cache directory" do
        @field.should_receive(:prepare_cache_directory).once.with
        
        @field.cache
      end
      it "tells the indexer to index" do
        @generated.should_receive(:generate_caches).once.with
        
        @field.cache
      end
    end
    describe "prepare_cache_directory" do
      before(:each) do
        @field = Configuration::Field.new :some_name, :some_tokenizer
        
        @field.stub! :cache_directory => :some_cache_directory
      end
      it "tells the FileUtils to mkdir_p" do
        FileUtils.should_receive(:mkdir_p).once.with :some_cache_directory
        
        @field.prepare_cache_directory
      end
    end
    describe "index" do
      before(:each) do
        @field = Configuration::Field.new :some_name, :some_tokenizer
        @field.stub! :prepare_cache_directory
        
        @indexer = stub :indexer, :index => nil
        @field.stub! :indexer => @indexer
      end
      it "prepares the cache directory" do
        @field.should_receive(:prepare_cache_directory).once.with
        
        @field.index
      end
      it "tells the indexer to index" do
        @indexer.should_receive(:index).once.with
        
        @field.index
      end
    end
    describe "source" do
      context "with source" do
        before(:each) do
          @field = Configuration::Field.new :some_name, :some_tokenizer, :source => :some_given_source

          @type = stub :type, :name => :some_type
          @field.type = @type
        end
        it "returns the given source" do
          @field.source.should == :some_given_source
        end
      end
      context "without source" do
        before(:each) do
          @field = Configuration::Field.new :some_name, :some_tokenizer

          @type = stub :type, :name => :some_type, :source => :some_type_source
          @field.type = @type
        end
        it "returns the type's source" do
          @field.source.should == :some_type_source
        end
      end
    end
    context "name symbol" do
      before(:each) do
        @field = Configuration::Field.new :some_name, :some_tokenizer
        
        @type = stub :type, :name => :some_type
        @field.type = @type
      end
      describe "search_index_file_name" do
        it "returns the right file name" do
          @field.search_index_file_name.should == 'some/search/root/index/test/some_type/prepared_some_name_index.txt'
        end
      end
      describe "generate_qualifiers_from" do
        context "with qualifiers" do
          it "uses the qualifiers" do
            @field.generate_qualifiers_from(:qualifiers => :some_qualifiers).should == :some_qualifiers
          end
        end
        context "without qualifiers" do
          context "with qualifier" do
            it "uses the [qualifier]" do
              @field.generate_qualifiers_from(:qualifier => :some_qualifier).should == [:some_qualifier]
            end
          end
          context "without qualifier" do
            context "with name" do
              it "uses the [name]" do
                @field.generate_qualifiers_from(:nork => :blark).should == [:some_name]
              end
            end
          end
        end
      end
    end
    context "name string" do
      before(:each) do
        @field = Configuration::Field.new 'some_name', :some_tokenizer
      end
      describe "generate_qualifiers_from" do
        context "without qualifiers" do
          context "without qualifier" do
            context "with name" do
              it "uses the [name]" do
                @field.generate_qualifiers_from(:nork => :blark).should == [:some_name]
              end
            end
          end
        end
      end
    end
  end
  
end