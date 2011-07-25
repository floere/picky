require 'spec_helper'

describe Picky::Loader do

  before(:each) do
    @loader_path = File.absolute_path("#{File.dirname(__FILE__)}/../../lib/picky/loader.rb")
  end
  
  describe 'load_application' do
    before(:each) do
      Picky::Application.stub! :reload
    end
    it "does ok" do
      lambda { Picky::Loader.load_application }.should_not raise_error
    end
  end
  
  describe 'load_framework' do
    before(:each) do
      Picky::Loader.stub! :load_relative
    end
    it "does ok" do
      lambda { Picky::Loader.load_framework }.should_not raise_error
    end
  end
  
  describe 'load_self' do
    before(:each) do
      Picky::Loader.stub! :load
      Picky::Loader.stub! :exclaim
    end
    after(:each) do
      Picky::Loader.load_self
    end
    it 'should load __SELF__' do
      Picky::Loader.should_receive(:load).once.with @loader_path
    end
  end

  describe 'reload' do
    before(:each) do
      load @loader_path
      Picky::Loader.stub! :exclaim
      Picky::Loader.stub! :load_framework
      Picky::Loader.stub! :load_application
      Dir.stub! :chdir
    end
    after(:each) do
      Picky::Loader.reload
    end
    it 'should call the right methods in order' do
      Picky::Loader.should_receive(:load_self).ordered
      Picky::Loader.should_receive(:load_framework).ordered
      Picky::Loader.should_receive(:load_application).ordered
    end
    it 'should load itself only once' do
      Picky::Loader.should_receive(:load_self).once
    end
    # it 'should load the app only once' do
    #   Loader.should_receive(:load_framework).once
    # end
  end

end