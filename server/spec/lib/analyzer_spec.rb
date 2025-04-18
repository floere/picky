# encoding: utf-8
#
require 'spec_helper'

require_relative '../../lib/picky/analyzer'

describe Analyzer do

  let(:analyzer) { described_class.new }

  context 'after initialize' do
    it 'sets the comments' do
      analyzer.comments.should == []
    end
    it 'sets the analysis' do
      analyzer.analysis.should == {}
    end
  end

end
