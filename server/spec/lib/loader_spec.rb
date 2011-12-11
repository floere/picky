require 'spec_helper'

describe Picky::Loader do

  before(:each) do
    described_class.stub! :exclaim
    @loader_path = File.absolute_path("#{File.dirname(__FILE__)}/../../lib/picky/loader.rb")
  end

  describe 'load self and framework' do
    it 'it is quick' do
      performance_of do
        described_class.load_self
        described_class.load_framework
      end.should < 0.025
    end
  end

  describe 'load_application' do
    it 'does ok' do
      Kernel.should_receive(:load).once.with 'spec/test_directory/app.rb'

      lambda { described_class.load_application }.should_not raise_error
    end
    it 'loads correctly' do
      described_class.should_receive(:load_user).once.with 'app'

      described_class.load_application
    end
    it 'loads correctly' do
      described_class.should_receive(:load_user).once.with 'special_app'

      described_class.load_application 'special_app'
    end
  end

  describe 'load_framework' do
    before(:each) do
      described_class.stub! :load_relative
    end
    it 'does ok' do
      lambda { described_class.load_framework }.should_not raise_error
    end
  end

  describe 'load_self' do
    before(:each) do
      described_class.stub! :load
    end
    after(:each) do
      described_class.load_self
    end
    it 'should load __SELF__' do
      Kernel.should_receive(:load).once.with @loader_path
    end
  end

  describe 'reload' do
    before(:each) do
      load @loader_path
      described_class.stub! :load_framework
      described_class.stub! :load_application
      Dir.stub! :chdir
    end
    it 'should call the right methods in order' do
      described_class.should_receive(:load_self).ordered
      described_class.should_receive(:load_framework).ordered
      described_class.should_receive(:load_application).ordered

      described_class.reload
    end
    it 'should load itself only once' do
      described_class.should_receive(:load_self).once

      described_class.reload
    end
    # it 'can load a specific app' do
    #   described_class.should_receive(:load_application).once.with 'special_app'
    #
    #   described_class.reload 'special_app'
    # end
  end

  describe 'load' do
    before(:each) do
      load @loader_path
      described_class.stub! :load_framework
      described_class.stub! :load_application
      Dir.stub! :chdir
    end
    after(:each) do
      described_class.load
    end
    it 'should call the right methods in order' do
      described_class.should_receive(:load_self).ordered
      described_class.should_receive(:load_framework).ordered
      described_class.should_receive(:load_application).ordered
    end
    it 'should load itself only once' do
      described_class.should_receive(:load_self).once
    end
  end

end