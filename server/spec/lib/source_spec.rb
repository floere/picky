require 'spec_helper'

describe Picky::Source do
  context 'unblock_source' do
    context 'with block' do
      it 'unblocks' do
        result = described_class.from -> { :some_source }, false

        result.call == :some_source
      end
    end
    context 'with #each' do
      it 'takes the source directly' do
        described_class.from([:some_source], true) == :some_source
      end
      it 'takes the source directly' do
        described_class.from([:some_source], false) == :some_source
      end
    end
  end
  context 'extract_source' do
    context 'block with source hash' do
      it 'extracts a source' do
        described_class.from(-> {}, false).should be_kind_of(Proc)
      end
    end
    context 'each source' do
      let(:source) do
        Class.new do
          def each; end
        end.new
      end
      it 'extracts a source' do
        described_class.from(source, false).should == source
      end
    end
    context 'invalid source with nil not ok' do
      it 'raises with a nice error message' do
        expect do
          described_class.from Object.new, false
        end.to raise_error(<<~ERROR)
          The source should respond to either the method #each or
          it can be a lambda/block, returning such a source.
        ERROR
      end
      it 'raises with a nice error message' do
        expect do
          described_class.from Object.new, false, 'some_index'
        end.to raise_error(<<~ERROR)
          The source for some_index should respond to either the method #each or
          it can be a lambda/block, returning such a source.
        ERROR
      end
    end
    context 'with nil ok' do
      it 'simply returns nil back' do
        described_class.from(nil, true).should.nil?
      end
    end
  end
end
