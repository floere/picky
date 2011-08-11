# encoding: utf-8
require 'spec_helper'

describe Picky::Generators::Selector do
  
  describe "main class" do
    before(:each) do
      @selector = Picky::Generators::Selector.new
    end
    
    describe "generator_for_class" do
      it "should return me a generator for the given class" do
        @selector.generator_for_class(Picky::Generators::Server::Classic, :identifier, :some_args).should be_kind_of(Picky::Generators::Server::Classic)
      end
    end
    
    describe "generator_for" do
      it "should not raise if a generator is available" do
        lambda { @selector.generator_for('all_in_one', 'some_project') }.should_not raise_error
      end
      it "should not raise if a generator is available" do
        lambda { @selector.generator_for('sinatra_client', 'some_project') }.should_not raise_error
      end
      it "should not raise if a generator is available" do
        lambda { @selector.generator_for('classic_server', 'some_project') }.should_not raise_error
      end
      it "should not raise if a generator is available" do
        lambda { @selector.generator_for('sinatra_server', 'some_project') }.should_not raise_error
      end
      it "should raise if a generator is not available" do
        lambda { @selector.generator_for('blarf', 'gnorf') }.should raise_error(Picky::Generators::NotFoundException)
      end
    end
    
    describe "generate" do
      it "should raise a NoGeneratorException if called with the wrong params" do
        lambda { @selector.generate('blarf', 'gnorf') }.should raise_error(Picky::Generators::NotFoundException)
      end
      it "should not raise on the right params" do
        @selector.stub! :generator_for_class => stub(:generator, :generate => nil)
        
        lambda { @selector.generate('sinatra_client', 'some_project') }.should_not raise_error
      end
    end
  end
  
end