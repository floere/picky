# encoding: utf-8
#
require 'spec_helper'

# We need to load the CLI file explicitly as the CLI is not loaded with the Loader (not needed in the server, only for script runs).
#
require File.expand_path '../../../lib/picky/cli', __FILE__

# TODO Finish this prototype Spec, redesign.
#
describe Picky::CLI do
  
  describe 'instance' do
    before(:each) do
      @cli = Picky::CLI.new
    end
    describe 'executor_class_for' do
      it 'returns Help by default' do
        @cli.executor_class_for.should == [Picky::CLI::Help]
      end
      it 'returns Generator for generate' do
        @cli.executor_class_for(:generate).should == [Picky::CLI::Generate, "sinatra_client | unicorn_server | empty_unicorn_server", "app_directory_name (optional)"]
      end
      it 'returns Help for help' do
        @cli.executor_class_for(:help).should == [Picky::CLI::Help]
      end
      it 'returns Statistics for stats' do
        @cli.executor_class_for(:stats).should == [Picky::CLI::Statistics, "logfile, e.g. log/search.log", "port (optional)"]
      end
    end
  end
  
  describe Picky::CLI::Base do
    before(:each) do
      @executor = Picky::CLI::Base.new
    end
    describe 'usage' do
      it 'calls puts with an usage' do
        @executor.should_receive(:puts).once.with "Usage\n  picky some_name <param1> <param 2 (optional)>"
        
        @executor.usage :some_name, [:param1, 'param 2 (optional)']
      end
    end
    describe 'params_to_s' do
      it 'returns the right string' do
        @executor.params_to_s([:param1, 'param 2 (optional)']).should == '<param1> <param 2 (optional)>'
      end
    end
  end
  
end