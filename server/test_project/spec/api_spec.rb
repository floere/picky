# coding: utf-8
#
require 'spec_helper'
require 'picky-client/spec'

# bundle exec rspec spec/api_spec.rb
#
describe "API" do
  
  it 'offers a number of index accessors' do

    # Indexes.index
    # Indexes.reload
    # Indexes.reindex
    # Indexes[:symbol_keys].index
    # Indexes[:symbol_keys].reload
    # Indexes[:symbol_keys].reindex    
    # Indexes[:symbol_keys][:text].index
    # Indexes[:symbol_keys][:text].reload
    # Indexes[:symbol_keys][:text].reindex
    
    # Indexing.
    #
    Indexes.indexing[:symbol_keys][:text]
    
    Indexes.indexing[:symbol_keys][:text].index
    Indexes.indexing[:symbol_keys].index
    # Indexes.index
    
    # Indexes while running.
    #
    Indexes.indexed[:symbol_keys][:text]

    Indexes.indexed[:symbol_keys][:text].load_from_cache
    Indexes.indexed[:symbol_keys].load_from_cache
    Indexes.load_from_cache

    # Indexes.indexed[:symbol_keys][:text].reload
    # Indexes.indexed[:symbol_keys].reload
    # Indexes.reload
    
    # Both.
    #
    # reindex == index & reload. Ok?
    #
    # Indexes[:symbol_keys][:text]
    # 
    # Indexes[:symbol_keys][:text].reindex
    # Indexes[:symbol_keys].reindex
    # Indexes.reindex
    
  end

end