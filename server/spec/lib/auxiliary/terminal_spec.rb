# encoding: utf-8
#
require 'spec_helper'

# We need to load the Statistics file explicitly as the Statistics
# are not loaded with the Loader (not needed in the server, only for script runs).
#
require File.expand_path '../../../../lib/picky/auxiliary/terminal', __FILE__

describe Terminal do
  
  let(:terminal) { described_class.new('/some/url') }
  
  before(:each) do
    terminal.stub! :search => { :total => 0, :duration => 0.01 }
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