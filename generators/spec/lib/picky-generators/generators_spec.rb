# encoding: utf-8
require 'spec_helper'

describe Picky::Generators do
  
  describe "main class" do
    before(:each) do
      @generators = Picky::Generators.new
    end
    
    describe "generator_for_class" do
      it "should return me a generator for the given class" do
        @generators.generator_for_class(Picky::Generator::Project, :identifier, :some_args).should be_kind_of(Picky::Generators::Unicorn)
      end
    end
    
    describe "generator_for" do
      it "should not raise if a generator is available" do
        lambda { @generators.generator_for('sinatra', 'some_project') }.should_not raise_error
      end
      it "should raise if a generator is not available" do
        lambda { @generators.generator_for('blarf', 'gnorf') }.should raise_error(Picky::Generators::NotFoundException)
      end
      it "should return a generator if it is available" do
        @generators.generator_for('sinatra', 'some_project').should be_kind_of(Picky::Generators::Unicorn)
      end
    end
    
    describe "generate" do
      it "should raise a NoGeneratorException if called with the wrong params" do
        lambda { @generators.generate(['blarf', 'gnorf']) }.should raise_error(Picky::Generators::NotFoundException)
      end
      it "should not raise on the right params" do
        @generators.stub! :generator_for_class => stub(:generator, :generate => nil)
        
        lambda { @generators.generate(['sinatra', 'some_project']) }.should_not raise_error
      end
    end
  end
  
  describe Picky::Generators::Unicorn do
    
    before(:each) do
      @generators = Picky::Generators::Unicorn.new :identifier, 'some_name', []
      @generators.stub! :exclaim
    end
    
    context "after initialize" do
      it "should have a prototype project basedir" do
        lambda {
          @generators.prototype_project_basedir
        }.should_not raise_error
      end
      it "should have a name" do
        @generators.name.should == 'some_name'
      end
    end
    
    describe "prototype_project_basedir" do
      it "should be the right basedir" do
        @generators.prototype_project_basedir.should == File.expand_path('../../../identifier_prototype', __FILE__)
      end
    end
    
    describe "generate" do
      it "should do things in order" do
        @generators.should_receive(:create_target_directory).once.ordered
        @generators.should_receive(:copy_all_files).once.ordered
        
        @generators.generate
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
        
        test_filename = File.expand_path 'some/file/name', @generators.prototype_project_basedir
        
        @generators.target_filename_for(test_filename).should == 'some_target_directory/some/file/name'
      end
    end
    
    describe "generate" do
      it "should copy recursively" do
        @generators.should_receive(:create_target_directory).once.with
        @generators.should_receive(:copy_all_files).once.with
        
        @generators.generate
      end
    end
    
    describe "target_directory" do
      it "should return the right dir name" do
        @generators.target_directory.should == File.expand_path('../../../some_name', __FILE__)
      end
    end
    
  end
  
end