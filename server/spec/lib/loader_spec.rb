require 'spec_helper'

describe Loader do

  before(:each) do
    @loader_path = File.absolute_path("#{File.dirname(__FILE__)}/../../lib/picky/loader.rb")
    Configuration.stub! :apply
    Indexes.stub! :setup
  end

  describe 'load_self' do
    before(:each) do
      Loader.stub! :load
      Loader.stub! :exclaim
    end
    after(:each) do
      Loader.load_self
    end
    it 'should load __SELF__' do
      Loader.should_receive(:load).once.with @loader_path
    end
  end

  describe 'reload' do
    before(:each) do
      load @loader_path
      Loader.stub! :exclaim
      Loader.stub! :load_framework
      Loader.stub! :load_application
      Dir.stub! :chdir
    end
    after(:each) do
      Loader.reload
    end
    it 'should call the right methods in order' do
      Loader.should_receive(:load_self).ordered
      Loader.should_receive(:load_framework).ordered
      Loader.should_receive(:load_application).ordered
    end
    it 'should load itself only once' do
      Loader.should_receive(:load_self).once
    end
    # it 'should load the app only once' do
    #   Loader.should_receive(:load_framework).once
    # end
  end

end