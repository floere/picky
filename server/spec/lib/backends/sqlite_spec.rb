require 'spec_helper'

require 'sqlite3'

describe Picky::Backends::SQLite do

  # context 'with options' do
  #   before(:each) do
  #     @backend = described_class.new inverted:      Picky::Backends::SQLite::Value.new(:unimportant),
  #                                    weights:       Picky::Backends::SQLite::Array.new(:unimportant),
  #                                    similarity:    Picky::Backends::SQLite::Value.new(:unimportant),
  #                                    configuration: Picky::Backends::SQLite::Array.new(:unimportant)
  #
  #     @backend.stub! :timed_exclaim
  #   end
  #
  #   describe 'create_...' do
  #     [
  #       [:inverted,      Picky::Backends::SQLite::Value],
  #       [:weights,       Picky::Backends::SQLite::Array],
  #       [:similarity,    Picky::Backends::SQLite::Value],
  #       [:configuration, Picky::Backends::SQLite::Array]
  #     ].each do |type, kind|
  #       it "creates and returns a(n) #{type} index" do
  #         @backend.send(:"create_#{type}",
  #                       stub(type, :index_path => "spec/temp/index/test/some_index/some_category_some_bundle_#{type}")
  #         ).should be_kind_of(kind)
  #       end
  #     end
  #   end
  # end
  #
  # context 'with lambda options' do
  #   before(:each) do
  #     @backend = described_class.new inverted:      ->(bundle){ Picky::Backends::SQLite::Value.new(bundle.index_path(:inverted)) },
  #                                    weights:       ->(bundle){ Picky::Backends::SQLite::Array.new(bundle.index_path(:weights)) },
  #                                    similarity:    ->(bundle){ Picky::Backends::SQLite::Value.new(bundle.index_path(:similarity)) },
  #                                    configuration: ->(bundle){ Picky::Backends::SQLite::Array.new(bundle.index_path(:configuration)) }
  #
  #     @backend.stub! :timed_exclaim
  #   end
  #
  #   describe 'create_...' do
  #     [
  #       [:inverted,      Picky::Backends::SQLite::Value],
  #       [:weights,       Picky::Backends::SQLite::Array],
  #       [:similarity,    Picky::Backends::SQLite::Value],
  #       [:configuration, Picky::Backends::SQLite::Array]
  #     ].each do |type, kind|
  #       it "creates and returns a(n) #{type} index" do
  #         to_a_able_stub = Object.new
  #         to_a_able_stub.stub! :index_path => "spec/temp/index/test/some_index/some_category_some_bundle_#{type}"
  #         @backend.send(:"create_#{type}", to_a_able_stub).should be_kind_of(kind)
  #       end
  #     end
  #   end
  # end

  context 'without options' do
    before(:each) do
      @backend = described_class.new

      @backend.stub! :timed_exclaim
    end

    describe 'create_...' do
      [
        [:inverted,      Picky::Backends::SQLite::Array],
        [:weights,       Picky::Backends::SQLite::Value],
        [:similarity,    Picky::Backends::SQLite::Array],
        [:configuration, Picky::Backends::SQLite::Value]
      ].each do |type, kind|
        it "creates and returns a(n) #{type} index" do
          @backend.send(:"create_#{type}",
                        stub(type, :index_path => "spec/temp/index/test/some_index/some_category_some_bundle_#{type}")
          ).should be_kind_of(kind)
        end
      end
    end

    describe "ids" do
      before(:each) do
        @combination1 = stub :combination1
        @combination2 = stub :combination2
        @combination3 = stub :combination3
        @combinations = [@combination1, @combination2, @combination3]
      end
      it "should intersect correctly" do
        @combination1.should_receive(:ids).once.with.and_return (1..100_000).to_a
        @combination2.should_receive(:ids).once.with.and_return (1..100).to_a
        @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

        @backend.ids(@combinations, :any, :thing).should == (1..10).to_a
      end
      it "should intersect symbol_keys correctly" do
        @combination1.should_receive(:ids).once.with.and_return (:'00001'..:'10000').to_a
        @combination2.should_receive(:ids).once.with.and_return (:'00001'..:'00100').to_a
        @combination3.should_receive(:ids).once.with.and_return (:'00001'..:'00010').to_a

        @backend.ids(@combinations, :any, :thing).should == (:'00001'..:'0010').to_a
      end
      it "should intersect correctly when intermediate intersect result is empty" do
        @combination1.should_receive(:ids).once.with.and_return (1..100_000).to_a
        @combination2.should_receive(:ids).once.with.and_return (11..100).to_a
        @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

        @backend.ids(@combinations, :any, :thing).should == []
      end
      it "should be fast" do
        @combination1.should_receive(:ids).once.with.and_return (1..100_000).to_a
        @combination2.should_receive(:ids).once.with.and_return (1..100).to_a
        @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

        performance_of { @backend.ids(@combinations, :any, :thing) }.should < 0.004
      end
      it "should be fast" do
        @combination1.should_receive(:ids).once.with.and_return (1..1000).to_a
        @combination2.should_receive(:ids).once.with.and_return (1..100).to_a
        @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

        performance_of { @backend.ids(@combinations, :any, :thing) }.should < 0.00015
      end
      it "should be fast" do
        @combination1.should_receive(:ids).once.with.and_return (1..1000).to_a
        @combination2.should_receive(:ids).once.with.and_return (901..1000).to_a
        @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

        performance_of { @backend.ids(@combinations, :any, :thing) }.should < 0.0001
      end
    end
  end

end
