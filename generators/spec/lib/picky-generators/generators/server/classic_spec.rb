# encoding: utf-8
#
require 'spec_helper'

describe Picky::Generators::Server::Classic do
  
  before(:each) do
    @classic = Picky::Generators::Server::Classic.new :classic_server, 'classic_server_dir_name'
    @classic.stub! :exclaim
  end
  
  context "after initialize" do
    it 'has the right identifier' do
      @classic.identifier.should == :classic_server
    end
    it 'has the right name' do
      @classic.name.should == 'classic_server_dir_name'
    end
    it 'has the right prototype dir' do
      @classic.prototype_basedir.should == File.expand_path('../../../../../../prototypes/server/classic', __FILE__)
    end
  end
  
  describe "generate" do
    it "should do things in order" do
      @classic.should_receive(:exclaim).once.ordered # Initial explanation
      @classic.should_receive(:create_target_directory).once.ordered
      @classic.should_receive(:copy_all_files).twice.ordered
      @classic.should_receive(:exclaim).at_least(9).times.ordered # Some user steps to do
      
      @classic.generate
    end
  end
  
end