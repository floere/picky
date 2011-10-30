# encoding: utf-8
require 'spec_helper'

describe Picky::Cores do
  
  describe ".forked" do
    context 'without fork' do
      before(:each) do
        Picky::Cores.stub! :fork? => false
      end
      it 'should not fork' do
        Process.should_receive(:fork).never
        
        described_class.forked([1,2]) do |element|
          
        end
      end
      it 'should yield the two elements' do
        result = []
        
        described_class.forked([1,2]) do |element|
          result << element
        end
        
        result.should == [1,2]
      end
      it 'should yield the two elements' do
        result = []
        
        described_class.forked([1,2], randomly: true) do |element|
          result << element
        end
        
        # This test remains like this because I
        # like the stupidity of it.
        #
        if result == [1,2]
          result.should == [1,2]
        else
          result.should == [2,1]
        end
      end
    end
    context 'with forking' do
      before(:each) do
        Picky::Cores.stub! :fork? => true
        Process.should_receive(:fork).any_number_of_times.and_yield
      end
      context "with array" do
        context "with block" do
          it "runs ok" do
            # TODO Problematic test. Should not raise the first time
            #
            Process.should_receive(:wait).once.and_raise Errno::ECHILD.new
            
            described_class.forked([1, 2]) do |e|

            end
          end
          it "yields the elements" do
            result = []
            
            described_class.forked([1, 2]) do |e|
              result << e
            end
            
            result.should == [1, 2]
          end
          it 'should not fork with amount option' do
            Process.should_receive(:fork).never

            described_class.forked([1,2], amount: 1) do |element|

            end
          end
          it 'should not fork with max == 1 option' do
            Process.should_receive(:fork).never

            described_class.forked([1,2], max: 1) do |element|

            end
          end
        end
        context "without block" do
          it "fails" do
            lambda {
              described_class.forked [1, 2]
            }.should raise_error("Block argument needed when running Cores.forked")
          end
        end
      end
      context "with empty array" do
        context "with block" do
          it "runs ok" do
            described_class.forked([]) do

            end
          end
        end
        context "without block" do
          it "runs ok" do
            described_class.forked []
          end
        end
      end
    end
  end
  
  describe 'fork?' do
    context 'with forking capabilities' do
      before(:all) do
        # Process.should_receive(:respond_to?).any_number_of_times.with(:fork).and_return true
      end
      it 'returns false' do
        Picky::Cores.fork?(0).should == false
      end
      it 'returns false' do
        Picky::Cores.fork?(1).should == false
      end
      it 'returns true' do
        Picky::Cores.fork?(2).should == true
      end
    end
  end
  
  describe 'number_of_cores' do
    before(:each) do
      @linux  = mock(:linux).as_null_object
      @darwin = mock(:darwin).as_null_object
      described_class.stub! :os_to_core_mapping => {
        'linux'  => @linux,
        'darwin' => @darwin
      }
    end
    context 'default' do
      before(:each) do
        described_class.stub! :platform => 'mswin'
      end
      it 'should return 1' do
        described_class.number_of_cores.should == 1
      end
    end
    context 'osx' do
      before(:each) do
        described_class.stub! :platform => 'i386-darwin9.8.0'
      end
      it 'should return whatever darwin returns' do
        @darwin.stub! :call => '1234'
        
        described_class.number_of_cores.should == 1234
      end
      it 'should call darwin' do
        @darwin.should_receive(:call).once
        
        described_class.number_of_cores
      end
      it 'should not call linux' do
        @linux.should_receive(:call).never
        
        described_class.number_of_cores
      end
    end
    context 'linux' do
      before(:each) do
        described_class.stub! :platform => 'x86_64-linux'
      end
      it 'should return whatever linux returns' do
        @linux.stub! :call => '1234'
        
        described_class.number_of_cores.should == 1234
      end
      it 'should call linux' do
        @linux.should_receive(:call).once
        
        described_class.number_of_cores
      end
      it 'should not call darwin' do
        @darwin.should_receive(:call).never
        
        described_class.number_of_cores
      end
    end
  end
  
end