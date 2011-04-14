# encoding: utf-8
#
require 'spec_helper'

# We need to load the Statistics file explicitly as the Statistics
# are not loaded with the Loader (not needed in the server, only for script runs).
#
require File.expand_path '../../../../lib/picky-client/aux/terminal', __FILE__

describe Picky::Terminal do
  
  let(:terminal) { described_class.new('/some/url') }
  
  describe 'backspace' do
    it 'works correctly' do
      terminal.should_receive(:chop_text).once.ordered.with()
      terminal.should_receive(:print).once.ordered.with "\e[1D \e[1D"
      terminal.should_receive(:flush).once.ordered.with()
      
      terminal.backspace
    end
  end
  
  describe 'write_results' do
    it 'works correctly' do
      terminal.should_receive(:move_to).once.ordered.with 0
      terminal.should_receive(:write).once.ordered.with "        0"
      terminal.should_receive(:move_to).once.ordered.with 10
      
      terminal.write_results nil
    end
    it 'works correctly' do
      terminal.should_receive(:move_to).once.ordered.with 0
      terminal.should_receive(:write).once.ordered.with "123456789"
      terminal.should_receive(:move_to).once.ordered.with 10
      
      terminal.write_results stub(:results, :total => 123456789)
    end
  end
  
  describe 'search' do
    before(:each) do
      @client = stub :client
      terminal.stub! :client => @client
      
      terminal.add_text 'hello'
    end
    it 'searches full correctly' do
      @client.should_receive(:search).once.with 'hello', :ids => 20
      
      terminal.search true
    end
    it 'searches full correctly' do
      terminal = described_class.new('/some/url', 33)
      terminal.stub! :client => @client
      
      @client.should_receive(:search).once.with '', :ids => 33
      
      terminal.search true
    end
    it 'searches live correctly' do
      @client.should_receive(:search).once.with 'hello', :ids => 0
      
      terminal.search
    end
    it 'searches live correctly' do
      @client.should_receive(:search).once.with 'hello', :ids => 0
      
      terminal.search false
    end
  end
  
  describe 'clear_ids' do
    it 'moves to the ids, then clears all' do
      terminal.should_receive(:move_to_ids).once.with()
      terminal.should_receive(:write).once.with " "*200
      
      terminal.clear_ids
    end
  end
  
  describe 'write_ids' do
    it 'writes the result\'s ids' do
      terminal.should_receive(:move_to_ids).once.with()
      terminal.should_receive(:write).once.with "=> []"
      
      terminal.write_ids stub(:results, :total => nil)
    end
    it 'writes the result\'s ids' do
      terminal.should_receive(:move_to_ids).once.with()
      terminal.should_receive(:write).once.with "=> [1, 2, 3]"
      
      terminal.write_ids stub(:results, :total => 3, :ids => [1, 2, 3])
    end
  end
  
  describe 'move_to_ids' do
    it 'moves to a specific place' do
      terminal.should_receive(:move_to).once.with 12
      
      terminal.move_to_ids
    end
    it 'moves to a specific place' do
      terminal.add_text 'test'
      
      terminal.should_receive(:move_to).once.with 16
      
      terminal.move_to_ids
    end
  end
  
  describe 'left' do
    it 'moves by amount' do
      terminal.should_receive(:print).once.ordered.with "\e[13D"
      terminal.should_receive(:flush).once.ordered
      
      terminal.left 13
    end
    it 'default is 1' do
      terminal.should_receive(:print).once.ordered.with "\e[1D"
      terminal.should_receive(:flush).once.ordered
      
      terminal.left
    end
  end
  
  describe 'right' do
    it 'moves by amount' do
      terminal.should_receive(:print).once.ordered.with "\e[13C"
      terminal.should_receive(:flush).once.ordered
      
      terminal.right 13
    end
    it 'default is 1' do
      terminal.should_receive(:print).once.ordered.with "\e[1C"
      terminal.should_receive(:flush).once.ordered
      
      terminal.right
    end
  end
  
  describe 'flush' do
    it 'flushes STDOUT' do
      STDOUT.should_receive(:flush).once.with()
      
      terminal.flush
    end
  end
  
end