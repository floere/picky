# encoding: utf-8
require 'spec_helper'

describe Picky::Generators do
  
  describe Picky::Generators::Base do
    
    before(:each) do
      @generators = Picky::Generators::Base.new :identifier, 'some_name', 'some/path'
      @generators.stub! :exclaim
    end
    
    context "after initialize" do
      it 'has the right identifier' do
        @generators.identifier.should == :identifier
      end
      it 'has the right name' do
        @generators.name.should == 'some_name'
      end
      it 'has the right prototype dir' do
        @generators.prototype_basedir.should == File.expand_path('../../../../../prototypes/some/path', __FILE__)
      end
    end
    
    describe "create_target_directory" do
      context "file exists" do
        before(:each) do
          File.stub! :exists? => true
        end
        it "should just tell the user that" do
          @generators.stub! :target_directory => :some_target_directory
          
          @generators.should_receive(:exists).once.with :some_target_directory
          
          @generators.create_target_directory
        end
        it "should not make the directory" do
          FileUtils.should_receive(:mkdir).never
          
          @generators.create_target_directory
        end
      end
      context "file does not exist" do
        before(:each) do
          File.stub! :exists? => false
          FileUtils.stub! :mkdir
        end
        it "should make the directory" do
          @generators.stub! :target_directory => :some_target_directory
          
          FileUtils.should_receive(:mkdir).once.with :some_target_directory
          
          @generators.create_target_directory
        end
        it "should tell the user" do
          @generators.stub! :target_directory => :some_target_directory
          
          @generators.should_receive(:created).once.with :some_target_directory
          
          @generators.create_target_directory
        end
      end
    end
    
    describe "target_filename_for" do
      it "should return the right filename" do
        @generators.stub! :target_directory => 'some_target_directory'
        
        test_filename = File.expand_path 'some/file/name', @generators.prototype_basedir
        
        @generators.target_filename_for(test_filename).should == 'some_target_directory/some/file/name'
      end
    end
    
    describe "target_directory" do
      it "should return the right dir name" do
        @generators.target_directory.should == File.expand_path('../../../../../some_name', __FILE__)
      end
    end
    
  end
  
end