# encoding: utf-8
#
require 'spec_helper'

describe Picky::Category, "Realtime API" do

  Thing = Struct.new :id, :text

  let(:category) do
    index    = Picky::Index.new :some_index_name
    category = described_class.new :text, index
  end

  it 'offers an add method' do
    category.add Thing.new(1, 'text')
  end
  it 'offers a remove method' do
    category.remove 1
  end
  it 'offers a replace method' do
    category.replace Thing.new(1, 'text')
  end
  it 'offers a << method' do
    category << Thing.new(1, 'text')
  end
  # it 'offers a >> method' do
  #   Thing.new(1, 'text') >> category # I mean, as long as we're dreaming.
  # end
  it 'offers an unshift method' do
    category.unshift Thing.new(1, 'text')
  end

end