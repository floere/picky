# encoding: utf-8
require 'spec_helper'

describe Picky::Generator do
  
  describe "main class" do
    before(:each) do
      @generator = Picky::Generator.new
    end
    
    describe "generator_for_class" do
      it "should return me a generator for the given class" do
        @generator.generator_for_class(Picky::Generator::Project, :some_args).should be_kind_of(Picky::Generator::Project)
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
      @generator = Picky::Generator::Project.new 'some_name', []
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
    
    describe "target_filename_for" do
      it "should return the right filename" do
        @generator.stub! :target_directory => 'some_target_directory'
        
        test_filename = File.expand_path File.join(@generator.prototype_project_basedir, '/some/file/name')
        
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
        @generator.target_directory.should == File.expand_path(File.join(__FILE__, '..', '..', '..', 'some_name'))
      end
    end
    
  end
  
end