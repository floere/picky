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
    
    describe "generate" do
      it "should copy recursively" do
        @generator.stub! :target_directory => 'target_directory'
        
        FileUtils.should_receive(:cp_r).once.with @generator.prototype_project_basedir, 'target_directory'
        
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