require 'spec_helper'

describe Picky::Sources::Base do
  context 'with the base class' do
    let(:source) { described_class.new }
    
    describe 'connect_backend' do
      it 'exists' do
        source.connect_backend
      end
    end
    
    describe 'take_snapshot' do
      it 'exists and takes a single parameter' do
        source.take_snapshot :some_index
      end
    end
  end
  
  context 'with subclass' do
    let(:take_snapshot_called) { 0 }
    let(:subclass) do
      Class.new(described_class) do
        def take_snapshot index
          index.call index
        end
      end.new
    end
    
    describe 'with snapshot' do
      it 'is called only once when called in nested blocks' do
        index = stub :index, :identifier => :some_index
        subclass.stub! :timed_exclaim

        index.should_receive(:call).once.with index

        subclass.with_snapshot(index) do
          subclass.with_snapshot(index) do
            subclass.with_snapshot(index) do

            end
          end
          subclass.with_snapshot(index) do
            subclass.with_snapshot(index) do

            end
          end
        end
      end
    end
  end
  
end