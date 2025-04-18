# encoding: utf-8
#
require 'spec_helper'

describe Picky::Backends::Memory::JSON do

  let(:backend) { described_class.new '/tmp/picky_test_cache' }
  
  describe 'dump_json' do
    it 'works with ascii characters' do
      backend.dump_json key: 'abc'
    end
    it 'works with cyrillic characters' do
      backend.dump_json key: 'й'
    end
    it 'works with ascii strings' do
      # See https://github.com/floere/picky/pull/69.
      #
      # Rails sets both encodings to UTF-8.
      #
      old_default_external = Encoding.default_external
      old_default_internal = Encoding.default_internal
      Encoding.default_external = 'UTF-8'
      Encoding.default_internal = 'UTF-8'
      
      ascii = "\xE5".force_encoding 'ASCII-8BIT'
      # ascii.encode('UTF-8') # Uncomment this to get the error mentioned in the pull request.
      backend.dump_json ascii => ascii # Pass in the string as both key and value
      
      # Reset encodings.
      #
      Encoding.default_external = old_default_external
      Encoding.default_internal = old_default_internal
    end
  end
  
end