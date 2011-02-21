require 'spec_helper'

describe 'Configuration::Index' do
  
  before(:each) do
    @index    = stub :index, :name => :some_index
    @category = stub :category, :name => :some_category
    @config = Configuration::Index.new @index, @category
  end
  
  describe "index_name" do
    it "returns the right thing" do
      @config.index_name.should == :some_index
    end
  end
  describe "category_name" do
    it "returns the right thing" do
      @config.category_name.should == :some_category
    end
  end
  
  describe "index_path" do
    it "caches" do
      @config.index_path(:some_bundle, :some_name).should_not equal(@config.index_path(:some_bundle, :some_name))
    end
    it "returns the right thing" do
      @config.index_path(:some_bundle, :some_name).should == 'spec/test_directory/index/test/some_index/some_category_some_bundle_some_name'
    end
  end
  
  # describe "file_name" do
  #   it "caches" do
  #     @config.file_name.should equal(@config.file_name)
  #   end
  #   it "returns the right thing" do
  #     @config.file_name.should == 'some_index_some_category'
  #   end
  # end
  
  describe "identifier" do
    it "caches" do
      @config.identifier.should equal(@config.identifier)
    end
    it "returns the right thing" do
      @config.identifier.should == 'some_index:some_category'
    end
  end
  describe "index_root" do
    it "caches" do
      @config.index_root.should equal(@config.index_root)
    end
    it "returns the right thing" do
      @config.index_root.should == 'spec/test_directory/index'
    end
  end
  describe "index_directory" do
    it "caches" do
      @config.index_directory.should equal(@config.index_directory)
    end
    it "returns the right thing" do
      @config.index_directory.should == 'spec/test_directory/index/test/some_index'
    end
  end
  describe "prepared_index_path" do
    it "caches" do
      @config.prepared_index_path.should equal(@config.prepared_index_path)
    end
    it "returns the right thing" do
      @config.prepared_index_path.should == 'spec/test_directory/index/test/some_index/prepared_some_category_index'
    end
  end
  describe "prepare_index_directory" do
    it "calls the right thing" do
      FileUtils.should_receive(:mkdir_p).once.with 'spec/test_directory/index/test/some_index'
      
      @config.prepare_index_directory
    end
  end
  
end