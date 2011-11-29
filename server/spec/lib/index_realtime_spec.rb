# encoding: utf-8
#
require 'spec_helper'

describe Picky::Index, "Realtime API" do

  Thing = Struct.new :id, :text

  let(:index) do
    described_class.new :some_index_name do
      category :text
    end
  end

  it 'offers an add method' do
    index.add Thing.new(1, 'text')
  end
  it 'offers a remove method' do
    index.remove 1
  end
  it 'offers a replace method' do
    index.replace Thing.new(1, 'text')
  end
  it 'offers a << method' do
    index << Thing.new(1, 'text')
  end
  # it 'offers a >> method' do
  #   Thing.new(1, 'text') >> index # I mean, as long as we're dreaming.
  # end
  it 'offers an unshift method' do
    index.unshift Thing.new(1, 'text')
  end

end