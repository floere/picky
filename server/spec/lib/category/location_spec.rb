require 'spec_helper'

describe Picky::Category::Location do
  let(:category) do
    category = Class.new do
      attr_accessor :exact, :partial
    end.new
    category.exact = :exact
    described_class.install_on(category, 1, 1, 1)
  end

  describe 'tokenizer' do
    it 'installs a basic tokenizer' do
      category.tokenizer.should be_kind_of(Picky::Tokenizer)
    end
  end

  describe 'bundles' do
    it 'installs an exact bundle' do
      category.exact.should be_kind_of(Picky::Wrappers::Bundle::Location)
    end
    it 'installs an partial bundle' do
      category.partial.should be_kind_of(Picky::Wrappers::Bundle::Location)
    end
  end
end
