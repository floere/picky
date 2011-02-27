# encoding: utf-8
#
require 'spec_helper'

describe 'aliases' do
  it 'exists an Indexes class that is an instance of API::Indexes' do
    Indexes.class.should == IndexBundle
  end
end