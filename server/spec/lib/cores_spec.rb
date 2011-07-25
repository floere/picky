# encoding: utf-8
require 'spec_helper'

describe Picky::Cores do
  
  describe ".forked" do
    before(:each) do
      Process.should_receive(:fork).any_number_of_times.and_yield
    end
    context "with array" do
      context "with block" do
        it "runs ok" do
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
  
  describe 'number_of_cores' do
    before(:each) do
      @linux  = mock :linux,  :null_object => true
      @darwin = mock :darwin, :null_object => true
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