# encoding: utf-8
#
require 'spec_helper'

describe Index::Redis do
  
  let(:some_source) { stub :source, :harvest => nil }
  
  describe 'initialize' do
    it 'works' do
      described_class.new :some_name, source: some_source
    end
  end
  
end