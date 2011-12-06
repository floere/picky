# coding: utf-8
#
require 'spec_helper'
require 'picky-client/spec'

# bundle exec rspec spec/api_spec.rb
#
describe "API" do

  it 'offers a number of index accessors' do

    Picky::Indexes[:symbol_keys][:text].index
    Picky::Indexes[:symbol_keys][:text].load
    Picky::Indexes[:symbol_keys][:text].reindex

    Picky::Indexes[:symbol_keys].index
    Picky::Indexes[:symbol_keys].load
    Picky::Indexes[:symbol_keys].reindex

    # Indexes.index
    # Indexes.reload
    # Indexes.reindex

  end

end