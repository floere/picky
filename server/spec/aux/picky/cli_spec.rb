# encoding: utf-8
#
require 'spec_helper'

# We need to load the CLI file explicitly as the CLI is not loaded with the Loader (not needed in the server, only for script runs).
#
require File.expand_path '../../../../aux/picky/cli', __FILE__

describe Picky::CLI do
  
  describe '.mapping' do
    it 'returns the right mapping' do
      Picky::CLI.mapping.should == {
        :generate => [Picky::CLI::Generate, :"{sinatra_client,unicorn_server,empty_unicorn_server}", :app_directory_name],
        :help     => [Picky::CLI::Help],
        :live     => [Picky::CLI::Live, "host:port/path (default: localhost:8080/admin)", "port (default: 4568)"],
        :search   => [Picky::CLI::Search, :url_or_path, 'amount of ids (default 20)'],
        :stats    => [Picky::CLI::Statistics, :"logfile (e.g. log/search.log)", "port (default: 4567)"]
      }
    end
  end
  
  describe 'instance' do
    let(:cli) { described_class.new }
    describe 'execute' do
      it 'calls generate correctly' do
        Kernel.should_receive(:system).once.with 'picky-generate one two three'
        
        cli.execute 'generate', 'one', 'two', 'three'
      end
      it 'calls help correctly' do
        Kernel.should_receive(:puts).once.with <<-HELP
Possible commands:
  picky generate {sinatra_client,unicorn_server,empty_unicorn_server} app_directory_name
  picky help 
  picky live [host:port/path (default: localhost:8080/admin)] [port (default: 4568)]
  picky search url_or_path [amount of ids (default 20)]
  picky stats logfile (e.g. log/search.log) [port (default: 4567)]
HELP
        cli.execute 'help'
      end
      # it 'calls live and it does not fail' do
      #   cli.execute 'live'
      # end
      # it 'calls stats and it does not fail' do
      #   cli.execute 'stats', 'some/log/file.log'
      # end
    end
    describe 'executor_class_for' do
      it 'returns Help by default' do
        cli.executor_class_for.should == [Picky::CLI::Help]
      end
      it 'returns Generator for generate' do
        cli.executor_class_for(:generate).should == [Picky::CLI::Generate, :'{sinatra_client,unicorn_server,empty_unicorn_server}', :"app_directory_name"]
      end
      it 'returns Help for help' do
        cli.executor_class_for(:help).should == [Picky::CLI::Help]
      end
      it 'returns Live for live' do
        cli.executor_class_for(:live).should == [Picky::CLI::Live, "host:port/path (default: localhost:8080/admin)", "port (default: 4568)"]
      end
      it 'returns Search for stats' do
        cli.executor_class_for(:search).should == [Picky::CLI::Search, :url_or_path, "amount of ids (default 20)"]
      end
      it 'returns Statistics for stats' do
        cli.executor_class_for(:stats).should == [Picky::CLI::Statistics, :"logfile (e.g. log/search.log)", "port (default: 4567)"]
      end
      it 'returns Help for silly input' do
        cli.executor_class_for(:gagagagagagaga).should == [Picky::CLI::Help]
      end
    end
  end
  
  describe Picky::CLI::Live do
    let(:executor) { described_class.new }
  end
  
  describe Picky::CLI::Base do
    let(:executor) { described_class.new }
    describe 'usage' do
      it 'calls puts with an usage' do
        executor.should_receive(:puts).once.with "Usage:\n  picky some_name param1 [param2]"
        
        executor.usage :some_name, [:param1, 'param2']
      end
    end
    describe 'params_to_s' do
      it 'returns the right string' do
        executor.params_to_s([:param1, 'param2']).should == 'param1 [param2]'
      end
    end
  end
  
end