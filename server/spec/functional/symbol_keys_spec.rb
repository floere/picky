require 'spec_helper'
require 'ostruct'

describe 'Option symbol_keys' do
  let(:index) do
    Picky::Index.new(:results1) { symbol_keys true }
  end
  let(:try) do
    Picky::Search.new(index) { symbol_keys }
  end

  it 'returns results' do
    index.category :text

    thing = OpenStruct.new id: 1, text: 'ohai'
    other = OpenStruct.new id: 2, text: 'ohai kthxbye'

    index.add thing
    index.add other

    try.search('text:ohai').ids.should == [2, 1]
  end

  it 'works with facets' do
    index.category :text

    thing = OpenStruct.new id: 1, text: 'ohai'
    other = OpenStruct.new id: 2, text: 'ohai kthxbye'

    index.add thing
    index.add other

    index.facets(:text).should
    try.facets(:text).should == { ohai: 2, kthxbye: 1 }
  end

  it 'actually uses symbols - paranoia' do
    index.category :text

    thing = OpenStruct.new id: 1, text: 'ohai'

    index.add thing

    index[:text].exact.inverted[:ohai].should
    index[:text].exact.weights[:ohai].should
    index[:text].exact.realtime[1].should
    index[:text].exact.similarity[:ohai].should.nil?
  end

  it 'does the internals right - uses symbols' do
    index.category :text

    thing = OpenStruct.new id: 1, text: 'ohai'

    index.add thing

    index[:text].exact.inverted.should
    index[:text].exact.weights.should
    # TODO: This could be removed if sorting was always explicitly done.
    index[:text].exact.realtime.should
    index[:text].exact.similarity.should == {}
  end
end
