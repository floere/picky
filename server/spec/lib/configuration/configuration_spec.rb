# encoding: utf-8
require 'spec_helper'

describe Configuration do

  describe 'field' do
    it 'should define a new type' do
      Configuration::Field.should_receive(:new).once.with :some_name, :some_options

      Configuration.field :some_name, :some_options
    end
    it 'should respect the default' do
      Configuration::Field.should_receive(:new).once.with :some_name, {}

      Configuration.field :some_name
    end
  end

  describe 'type' do
    it 'should define a new type' do
      Configuration::Type.should_receive(:new).once.with :some_name, :some_field, :some_other_field

      Configuration.type :some_name, :some_field, :some_other_field
    end
  end

  describe 'indexes' do
    it 'should define the indexes and save' do
      indexes = mock :indexes

      Configuration::Indexes.should_receive(:new).once.with(:some_types).and_return indexes
      indexes.should_receive(:save).once.with

      Configuration.indexes :some_types
    end
  end

end