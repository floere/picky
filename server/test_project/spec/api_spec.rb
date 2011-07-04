# coding: utf-8
#
require 'spec_helper'
require 'picky-client/spec'

# bundle exec rspec spec/api_spec.rb
#
describe "API" do
  
  it 'offers a number of index accessors' do
    
    Indexes[:symbol_keys][:text].index
    Indexes[:symbol_keys][:text].reload
    Indexes[:symbol_keys][:text].reindex
    
    Indexes[:symbol_keys].index
    Indexes[:symbol_keys].reload
    Indexes[:symbol_keys].reindex
    
    # Indexes.index
    # Indexes.reload
    # Indexes.reindex
    
  end

end