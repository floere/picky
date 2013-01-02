# encoding: utf-8
#
require 'spec_helper'

describe "Error Messages" do

  context 'missing category methods' do
    let(:index) do
      Picky::Index.new :error_messages do
        category :author
        category :title
        category :text
      end
    end
    let(:thing) { Struct.new :id, :author }
    it 'throws good ones when dynamic indexing' do
      this = thing.new 1, "ohai"
      that = thing.new 2, "blah"

      index.add this
      index.add that
    end
    it 'throws good ones when static indexing' do
      thing = Struct.new :id, :author
    
      things = []
      things << thing.new(1, "ohai")
      things << thing.new(2, "blah")

      index.source things
      index.index
    end
  end

end