# encoding: utf-8
#
require 'spec_helper'

describe Picky::Generators::AllInOne::Sinatra do

  before(:each) do
    @sinatra = Picky::Generators::AllInOne::Sinatra.new :all_in_one, 'all_in_one_dir_name'
    @sinatra.stub! :exclaim
  end

  context "after initialize" do
    it 'has the right identifier' do
      @sinatra.identifier.should == :all_in_one
    end
    it 'has the right name' do
      @sinatra.name.should == 'all_in_one_dir_name'
    end
    it 'has the right prototype dir' do
      @sinatra.prototype_basedir.should == File.expand_path('../../../../../../prototypes/all_in_one/sinatra', __FILE__)
    end
  end

  describe "generate" do
    it "should do things in order" do
      @sinatra.should_receive(:exclaim).once.ordered # Initial explanation
      @sinatra.should_receive(:create_target_directory).once.ordered
      @sinatra.should_receive(:copy_all_files).twice.ordered
      @sinatra.should_receive(:exclaim).at_least(9).times.ordered # Some user steps to do

      @sinatra.generate
    end
  end

end