require 'spec_helper'

describe Picky::Sinatra do
  let(:extendee) { Class.new {} }

  it 'has no Picky specific methods' do
    -> { extendee.indexing }.should raise_error
  end
  it 'has no Picky specific methods' do
    -> { extendee.searching }.should raise_error
  end

  context 'after extending' do
    before(:each) do
      extendee.extend Picky::Sinatra
    end
    it 'has Picky specific methods' do
      extendee.send :indexing, splits_text_on: /something/
    end
    it 'has Picky specific methods' do
      extendee.send :searching, splits_text_on: /something/
    end
    it 'gets forwardd correctly' do
      Picky::Tokenizer.should_receive(:default_indexing_with).once.with some: 'option'

      extendee.send :indexing, some: 'option'
    end
    it 'gets forwardd correctly' do
      expect(Picky::Tokenizer).to receive(:default_searching_with).once.with(some: 'option')

      extendee.send :searching, some: 'option'
    end
  end
end
