# encoding: utf-8
require 'spec_helper'

describe Picky::Generator do
  
  describe "main class" do
    before(:each) do
      @generator = Picky::Generator.new
    end

    describe "generate" do
      it "should exist" do
        lambda { @generator.generate(['project', 'some_project']) }.should_not raise_error
      end
      it "should " do

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
    
  end
  
end