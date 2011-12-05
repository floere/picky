# encoding: utf-8
require 'spec_helper'

describe Picky::Parallelizer do

  context 'default params' do
    let(:parallelizer) { described_class.new }

    context 'without forking' do
      before(:each) do
        parallelizer.stub! :fork? => false
      end
    end
    context 'with forking' do
      before(:each) do
        parallelizer.stub! :fork? => true
      end
    end

    describe 'number_of_cores' do
      before(:each) do
        @linux  = mock(:linux).as_null_object
        @darwin = mock(:darwin).as_null_object
        parallelizer.stub! :os_to_core_mapping => {
          'linux'  => @linux,
          'darwin' => @darwin
        }
      end
      context 'default' do
        before(:each) do
          parallelizer.stub! :platform => 'mswin'
        end
        it 'should return 1' do
          parallelizer.number_of_cores.should == 1
        end
      end
      context 'osx' do
        before(:each) do
          parallelizer.stub! :platform => 'i386-darwin9.8.0'
        end
        it 'should return whatever darwin returns' do
          @darwin.stub! :call => '1234'

          parallelizer.number_of_cores.should == 1234
        end
        it 'should call darwin' do
          @darwin.should_receive(:call).once

          parallelizer.number_of_cores
        end
        it 'should not call linux' do
          @linux.should_receive(:call).never

          parallelizer.number_of_cores
        end
      end
      context 'linux' do
        before(:each) do
          parallelizer.stub! :platform => 'x86_64-linux'
        end
        it 'should return whatever linux returns' do
          @linux.stub! :call => '1234'

          parallelizer.number_of_cores.should == 1234
        end
        it 'should call linux' do
          @linux.should_receive(:call).once

          parallelizer.number_of_cores
        end
        it 'should not call darwin' do
          @darwin.should_receive(:call).never

          parallelizer.number_of_cores
        end
      end
    end

    describe 'fork?' do
      context 'with forking capabilities' do
        it 'returns true by default' do
          parallelizer.fork?.should == true
        end
        it 'returns false' do
          parallelizer.stub! :max_processes => 1

          parallelizer.fork?.should == false
        end
        it 'returns false' do
          parallelizer.stub! :max_processes => 2

          parallelizer.fork?.should == true
        end
      end
    end
  end

end