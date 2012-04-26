# encoding: utf-8
#
require 'spec_helper'

describe Picky::Backends::Memory::JSON do

  let(:backend) { described_class.new '/tmp/picky_test_cache' }
  
  describe "dump_json" do
    it "works with ascii characters" do
      backend.dump_json key: 'abc'
    end
    it "works with cyrillic characters" do
      backend.dump_json key: 'й'
    end
  end
  
end