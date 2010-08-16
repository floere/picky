require 'spec_helper'

describe Helpers::Cache do
  include Helpers::Cache

  describe "#cached" do
    attr_reader :store, :key
    before(:each) do
      @store = {}
      @key = 'some key'
    end
    describe "not yet cached" do
      it "should cache" do
        store.should_receive(:[]=).once.with(@key, 'value')
        cached @store, @key do
          'value'
        end
      end
    end
    describe "already cached" do
      before(:each) do
        cached @store, @key do
          'value'
        end
      end
      it "should not cache" do
        store.should_receive(:[]=).never
        cached @store, @key do
          'value'
        end
      end
    end
  end

end