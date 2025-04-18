# encoding: utf-8
#
require 'spec_helper'

describe Picky::Interfaces::LiveParameters::Unicorn do

  before(:each) do
    @parent = double :parent
    @child  = double :child
    IO.stub pipe: [@child, @parent]
    @parameters = described_class.new
    @parameters.stub :exclaim
  end

  describe Picky::Interfaces::LiveParameters::Unicorn::CouldNotUpdateConfigurationError do
    before(:each) do
      @error = Picky::Interfaces::LiveParameters::Unicorn::CouldNotUpdateConfigurationError.new :some_key, 'some message'
    end
  end

  describe 'querying_removes_characters' do
    it 'works' do
      expect do
        @parameters.querying_removes_characters
      end.to_not raise_error
    end
  end
  describe 'querying_stopwords' do
    it 'works' do
      expect do
        @parameters.querying_stopwords
      end.to_not raise_error
    end
  end
  describe 'querying_splits_text_on' do
    it 'works' do
      expect do
        @parameters.querying_splits_text_on
      end.to_not raise_error
    end
  end

  describe 'parameters' do
    context 'all goes well' do
      it 'does a few things in order' do
        @parameters.should_receive(:close_child).once.with(no_args).ordered
        @parameters.should_receive(:try_updating_configuration_with).once.with(a: :b).ordered
        @parameters.should_receive(:write_parent).once.with(a: :b).ordered
        @parameters.should_receive(:extract_configuration).once.with(no_args).ordered

        @parameters.parameters a: :b
      end
    end
    context 'updating failed' do
      before(:each) do
        @parameters.should_receive(:try_updating_configuration_with).and_raise Picky::Interfaces::LiveParameters::Unicorn::CouldNotUpdateConfigurationError.new(:a, 'hello')
      end
      it 'kills itself and returns' do
        @parameters.should_receive(:close_child).once.ordered
        @parameters.should_receive(:harakiri).once.ordered

        @parameters.parameters( a: :b ).should == { a: :ERROR }
      end
    end
  end

  describe 'harakiri' do
    before(:each) do
      Process.stub pid: :some_pid
    end
    it 'kills itself' do
      Process.should_receive(:kill).once.with :QUIT, :some_pid

      @parameters.harakiri
    end
  end

  describe 'write_parent' do
    before(:each) do
      Process.stub pid: :some_pid
    end
    it 'calls the parent' do
      @parent.should_receive(:write).once.with '[:some_pid, {:a=>:b}];;;'

      @parameters.write_parent a: :b
    end
  end

  describe 'close_child' do
    context 'child is closed' do
      before(:each) do
        @child.stub closed?: true
      end
      it 'does not receive close' do
        @child.should_receive(:close).never

        @parameters.close_child
      end
    end
    context 'child not yet closed' do
      before(:each) do
        @child.stub closed?: false
      end
      it 'does receives close' do
        @child.should_receive(:close).once.with no_args

        @parameters.close_child
      end
    end
  end

  describe 'kill_worker' do
    context 'all goes well' do
      it 'uses Process.kill' do
        Process.should_receive(:kill).once.with :some_signal, :some_pid

        @parameters.kill_worker :some_signal, :some_pid
      end
    end
    context 'there is no such process' do
      it 'uses Process.kill' do
        Process.should_receive(:kill).and_raise Errno::ESRCH.new

        @parameters.should_receive(:remove_worker).once.with :some_pid

        @parameters.kill_worker :some_signal, :some_pid
      end
    end
  end

  describe 'kill_each_worker_except' do
    context 'worker pid in the worker pids' do
      before(:each) do
        @parameters.stub worker_pids: [1,2,3,4]
      end
      it 'kills each except the one' do
        @parameters.should_receive(:kill_worker).once.with(:KILL, 1)
        @parameters.should_receive(:kill_worker).once.with(:KILL, 2)

        @parameters.should_receive(:kill_worker).once.with(:KILL, 4)

        @parameters.kill_each_worker_except 3
      end
    end
    context 'worker pid not in the worker pids (unrealistic, but...)' do
      before(:each) do
        @parameters.stub worker_pids: [1,2,3,4]
      end
      it 'kills each except the one' do
        @parameters.should_receive(:kill_worker).once.with(:KILL, 1)
        @parameters.should_receive(:kill_worker).once.with(:KILL, 2)
        @parameters.should_receive(:kill_worker).once.with(:KILL, 3)
        @parameters.should_receive(:kill_worker).once.with(:KILL, 4)

        @parameters.kill_each_worker_except 5
      end
    end
  end

end