# encoding: utf-8
#
require 'spec_helper'

describe Picky::Generators::Client::Sinatra do
  
  before(:each) do
    @sinatra = Picky::Generators::Client::Sinatra.new :sinatra_client, 'sinatra_client_dir_name'
    @sinatra.stub! :exclaim
  end
  
  context "after initialize" do
    it 'has the right identifier' do
      @sinatra.identifier.should == :sinatra_client
    end
    it 'has the right name' do
      @sinatra.name.should == 'sinatra_client_dir_name'
    end
    it 'has the right prototype dir' do
      @sinatra.prototype_basedir.should == File.expand_path('../../../../../../prototypes/client/sinatra', __FILE__)
    end
  end
  
  describe "generate" do
    it "should do things in order" do
      @sinatra.should_receive(:exclaim).twice.ordered # Initial explanation
      @sinatra.should_receive(:create_target_directory).once.ordered
      @sinatra.should_receive(:copy_all_files).twice.ordered
      @sinatra.should_receive(:exclaim).at_least(7).times.ordered # Some user steps to do
      
      @sinatra.generate
    end
  end
  
end