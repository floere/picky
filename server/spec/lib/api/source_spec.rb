require 'spec_helper'

describe Picky::API::Source do
  let(:object) do
    Class.new do
      include Picky::API::Source
    end.new
  end
  context 'unblock_source' do
    before(:each) do
      class << object
        def source_with source = nil, &block
          @source = source || block
        end
      end
    end
    context 'with block' do
      it 'unblocks' do
        object.source_with do
          :some_source
        end

        object.unblock_source == :some_source
      end
    end
    context 'with #each' do
      it 'takes the source directly' do
        object.source_with :some_source

        object.unblock_source == :some_source
      end
    end
  end
  context 'extract_source' do
    context 'block with source hash' do
      it 'extracts a source' do
        object.extract_source(Proc.new {}).should be_kind_of(Proc)
      end
    end
    context 'each source' do
      let(:source) do
        Class.new do
          def each

          end
        end.new
      end
      it 'extracts a source' do
        object.extract_source(source).should == source
      end
    end
    context 'invalid tokenizer' do
      it 'raises with a nice error message' do
        expect {
          object.extract_source Object.new
        }.to raise_error(<<-ERROR)
The source should respond to either the method #each or
it can be a lambda/block, returning such a source.
ERROR
      end
    end
    context 'with nil_ok option' do
      it 'simply returns nil back' do
        object.extract_source(nil, nil_ok: true).should == nil
      end
    end
  end
end