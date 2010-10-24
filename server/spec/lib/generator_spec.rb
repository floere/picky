# encoding: utf-8
require 'spec_helper'

describe Picky::Generator do
  
  describe "main class" do
    before(:each) do
      @generator = Picky::Generator.new
    end
    
    describe "generator_for_class" do
      it "should return me a generator for the given class" do
        @generator.generator_for_class(Picky::Generator::Project, :some_identifier, :some_args).should be_kind_of(Picky::Generator::Project)
      end
    end
    
    describe "generator_for" do
      it "should not raise if a generator is available" do
        lambda { @generator.generator_for('project', 'some_project') }.should_not raise_error
      end
      it "should raise if a generator is not available" do
        lambda { @generator.generator_for('blarf', 'gnorf') }.should raise_error(Picky::NoGeneratorException)
      end
      it "should return a generator if it is available" do
        @generator.generator_for('project', 'some_project').should be_kind_of(Picky::Generator::Project)
      end
    end
    
    describe "generate" do
      it "should raise a NoGeneratorException if called with the wrong params" do
        lambda { @generator.generate(['blarf', 'gnorf']) }.should raise_error(Picky::NoGeneratorException)
      end
      it "should not raise on the right params" do
        @generator.stub! :generator_for_class => stub(:generator, :generate => nil)
        
        lambda { @generator.generate(['project', 'some_project']) }.should_not raise_error
      end
    end
  end
  
  describe Picky::Generator::Project do
    
    before(:each) do
      @generator = Picky::Generator::Project.new :identifier, 'some_name', []
      @generator.stub! :exclaim
    end
    
    context "after initialize" do
      it "should have a prototype project basedir" do
        lambda {
          @generator.prototype_project_basedir
        }.should_not raise_error
      end
      it "should have a name" do
        @generator.name.should == 'some_name'
      end
    end
    
    describe "prototype_project_basedir" do
      it "should be the right basedir" do
        @generator.prototype_project_basedir.should == File.expand_path('../../../project_prototype', __FILE__)
      end
    end
    
    describe "generate" do
      it "should do things in order" do
        @generator.should_receive(:create_target_directory).once.ordered
        @generator.should_receive(:copy_all_files).once.ordered
        
        @generator.generate
      end
    end
    
    describe "create_target_directory" do
      context "file exists" do
        before(:each) do
          File.stub! :exists? => true
        end
        it "should just tell the user that" do
          @generator.stub! :target_directory => :some_target_directory
          
          @generator.should_receive(:exists).once.with :some_target_directory
          
          @generator.create_target_directory
        end
        it "should not make the directory" do
          FileUtils.should_receive(:mkdir).never
          
          @generator.create_target_directory
        end
      end
      context "file does not exist" do
        before(:each) do
          File.stub! :exists? => false
          FileUtils.stub! :mkdir
        end
        it "should make the directory" do
          @generator.stub! :target_directory => :some_target_directory
          
          FileUtils.should_receive(:mkdir).once.with :some_target_directory
          
          @generator.create_target_directory
        end
        it "should tell the user" do
          @generator.stub! :target_directory => :some_target_directory
          
          @generator.should_receive(:created).once.with :some_target_directory
          
          @generator.create_target_directory
        end
      end
    end
    
    describe "target_filename_for" do
      it "should return the right filename" do
        @generator.stub! :target_directory => 'some_target_directory'
        
        test_filename = File.expand_path 'some/file/name', @generator.prototype_project_basedir
        
        @generator.target_filename_for(test_filename).should == 'some_target_directory/some/file/name'
      end
    end
    
    describe "generate" do
      it "should copy recursively" do
        @generator.should_receive(:create_target_directory).once.with
        @generator.should_receive(:copy_all_files).once.with
        
        @generator.generate
      end
    end
    
    describe "target_directory" do
      it "should return the right dir name" do
        @generator.target_directory.should == File.expand_path('../../../some_name', __FILE__)
      end
    end
    
  end
  
end