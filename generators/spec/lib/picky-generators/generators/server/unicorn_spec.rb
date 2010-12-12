# encoding: utf-8
#
require 'spec_helper'

describe Picky::Generators::Server::Unicorn do
  
  before(:each) do
    @unicorn = Picky::Generators::Server::Unicorn.new :unicorn_server, 'unicorn_server_dir_name'
    @unicorn.stub! :exclaim
  end
  
  context "after initialize" do
    it 'has the right identifier' do
      @unicorn.identifier.should == :unicorn_server
    end
    it 'has the right name' do
      @unicorn.name.should == 'unicorn_server_dir_name'
    end
    it 'has the right prototype dir' do
      @unicorn.prototype_basedir.should == File.expand_path('../../../../../../prototypes/server/unicorn', __FILE__)
    end
  end
  
  describe "generate" do
    it "should do things in order" do
      @unicorn.should_receive(:exclaim).once.ordered # Initial explanation
      @unicorn.should_receive(:create_target_directory).once.ordered
      @unicorn.should_receive(:copy_all_files).once.ordered
      @unicorn.should_receive(:exclaim).at_least(9).times.ordered # Some user steps to do
      
      @unicorn.generate
    end
  end
  
end