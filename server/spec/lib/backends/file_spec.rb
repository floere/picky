require 'spec_helper'

describe Picky::Backends::File do

  # context 'with options' do
  #   before(:each) do
  #     @backend = described_class.new inverted:      Picky::Backends::File::Basic.new(:unimportant),
  #                                    weights:       Picky::Backends::File::Basic.new(:unimportant),
  #                                    similarity:    Picky::Backends::File::Basic.new(:unimportant),
  #                                    configuration: Picky::Backends::File::Basic.new(:unimportant)
  #
  #     @backend.stub :timed_exclaim
  #   end
  #
  #   describe 'create_...' do
  #     [
  #       [:inverted,      Picky::Backends::File::Basic],
  #       [:weights,       Picky::Backends::File::Basic],
  #       [:similarity,    Picky::Backends::File::Basic],
  #       [:configuration, Picky::Backends::File::Basic]
  #     ].each do |type, kind|
  #       it "creates and returns a(n) #{type} index" do
  #         @backend.send(:"create_#{type}",
  #                       double(type, :index_path => "spec/temp/index/test/some_index/some_category_some_bundle_#{type}")
  #         ).should be_kind_of(kind)
  #       end
  #     end
  #   end
  # end

  context 'without options' do
    before(:each) do
      @backend = described_class.new

      @backend.stub :timed_exclaim
    end
  
    describe 'create_...' do
      [
        [:inverted,      Picky::Backends::File::JSON],
        [:weights,       Picky::Backends::Memory::JSON],
        [:similarity,    Picky::Backends::File::JSON],
        [:configuration, Picky::Backends::File::JSON]
      ].each do |type, kind|
        it "creates and returns a(n) #{type} index" do
          @backend.send(:"create_#{type}",
                        double(type, :index_path => "spec/temp/index/test/some_index/some_category_some_bundle_#{type}")
          ).should be_kind_of(kind)
        end
      end
    end
  
    describe "ids" do
      before(:each) do
        @combination1 = double :combination1
        @combination2 = double :combination2
        @combination3 = double :combination3
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