require 'spec_helper'

describe 'Error messages for' do
  context 'missing category method' do
    let(:index) do
      Picky::Index.new :error_messages do
        category :author
        category :title
      end
    end
    let(:thing) { Struct.new :id, :author } # It is missing the title.
    it 'is informative when dynamic indexing' do
      this = thing.new 1, 'ohai'

      # For now, a NoMethodError is enough.
      #
      expect { index.add this }.to raise_error(NoMethodError)
    end
    it 'is informative when static indexing' do
      thing = Struct.new :id, :author

      index.source [thing.new(1, 'ohai')]

      # For now, a NoMethodError is enough.
      #
      expect { index.index }.to raise_error(NoMethodError)
    end
  end
end
