require 'spec_helper'

describe Picky::Backends::Redis do

  context 'with options' do
    before(:each) do
      @backend = described_class.new inverted:      Picky::Backends::Redis::Float.new(:unimportant, :unimportant),
                                     weights:       Picky::Backends::Redis::String.new(:unimportant, :unimportant),
                                     similarity:    Picky::Backends::Redis::Float.new(:unimportant, :unimportant),
                                     configuration: Picky::Backends::Redis::List.new(:unimportant, :unimportant)

      @backend.stub! :timed_exclaim
    end
  
    describe 'create_...' do
      [
        [:inverted,      Picky::Backends::Redis::Float],
        [:weights,       Picky::Backends::Redis::String],
        [:similarity,    Picky::Backends::Redis::Float],
        [:configuration, Picky::Backends::Redis::List]
      ].each do |type, kind|
        it "creates and returns a(n) #{type} index" do
          @backend.send(:"create_#{type}",
                        stub(type, :identifier => "some_identifier:#{type}")
          ).should be_kind_of(kind)
        end
      end
    end
  end
  
  context 'with lambda options' do
    before(:each) do
      @backend = described_class.new inverted:      ->(client, bundle){ Picky::Backends::Redis::Float.new(client, bundle.identifier(:inverted)) },
                                     weights:       ->(client, bundle){ Picky::Backends::Redis::String.new(client, bundle.identifier(:weights)) },
                                     similarity:    ->(client, bundle){ Picky::Backends::Redis::Float.new(client, bundle.identifier(:similarity)) },
                                     configuration: ->(client, bundle){ Picky::Backends::Redis::List.new(client, bundle.identifier(:configuration)) }

      @backend.stub! :timed_exclaim
    end
  
    describe 'create_...' do
      [
        [:inverted,      Picky::Backends::Redis::Float],
        [:weights,       Picky::Backends::Redis::String],
        [:similarity,    Picky::Backends::Redis::Float],
        [:configuration, Picky::Backends::Redis::List]
      ].each do |type, kind|
        it "creates and returns a(n) #{type} index" do
          to_a_able_stub = Object.new
          to_a_able_stub.stub! :identifier => "some_identifier:#{type}"
          @backend.send(:"create_#{type}", to_a_able_stub).should be_kind_of(kind)
        end
      end
    end
  end

  context 'without options' do
    before(:each) do
      @backend = described_class.new

      @backend.stub! :timed_exclaim
    end
  
    describe 'create_...' do
      [
        [:inverted,      Picky::Backends::Redis::List],
        [:weights,       Picky::Backends::Redis::Float],
        [:similarity,    Picky::Backends::Redis::List],
        [:configuration, Picky::Backends::Redis::String]
      ].each do |type, kind|
        it "creates and returns a(n) #{type} index" do
          @backend.send(:"create_#{type}",
                        stub(type, :identifier => "some_identifier:#{type}")
          ).should be_kind_of(kind)
        end
      end
    end

    # TODO
    #
    # describe "ids" do
    #   before(:each) do
    #     @combination1 = stub :combination1
    #     @combination2 = stub :combination2
    #     @combination3 = stub :combination3
    #     @combinations = [@combination1, @combination2, @combination3]
    #   end
    #   it "should intersect correctly" do
    #     @combination1.should_receive(:ids).once.with.and_return (1..100_000).to_a
    #     @combination2.should_receive(:ids).once.with.and_return (1..100).to_a
    #     @combination3.should_receive(:ids).once.with.and_return (1..10).to_a
    # 
    #     @backend.ids(@combinations, :any, :thing).should == (1..10).to_a
    #   end
    #   it "should intersect symbol_keys correctly" do
    #     @combination1.should_receive(:ids).once.with.and_return (:'00001'..:'10000').to_a
    #     @combination2.should_receive(:ids).once.with.and_return (:'00001'..:'00100').to_a
    #     @combination3.should_receive(:ids).once.with.and_return (:'00001'..:'00010').to_a
    # 
    #     @backend.ids(@combinations, :any, :thing).should == (:'00001'..:'0010').to_a
    #   end
    #   it "should intersect correctly when intermediate intersect result is empty" do
    #     @combination1.should_receive(:ids).once.with.and_return (1..100_000).to_a
    #     @combination2.should_receive(:ids).once.with.and_return (11..100).to_a
    #     @combination3.should_receive(:ids).once.with.and_return (1..10).to_a
    # 
    #     @backend.ids(@combinations, :any, :thing).should == []
    #   end
    #   it "should be fast" do
    #     @combination1.should_receive(:ids).once.with.and_return (1..100_000).to_a
    #     @combination2.should_receive(:ids).once.with.and_return (1..100).to_a
    #     @combination3.should_receive(:ids).once.with.and_return (1..10).to_a
    # 
    #     performance_of { @backend.ids(@combinations, :any, :thing) }.should < 0.004
    #   end
    #   it "should be fast" do
    #     @combination1.should_receive(:ids).once.with.and_return (1..1000).to_a
    #     @combination2.should_receive(:ids).once.with.and_return (1..100).to_a
    #     @combination3.should_receive(:ids).once.with.and_return (1..10).to_a
    # 
    #     performance_of { @backend.ids(@combinations, :any, :thing) }.should < 0.00015
    #   end
    #   it "should be fast" do
    #     @combination1.should_receive(:ids).once.with.and_return (1..1000).to_a
    #     @combination2.should_receive(:ids).once.with.and_return (901..1000).to_a
    #     @combination3.should_receive(:ids).once.with.and_return (1..10).to_a
    # 
    #     performance_of { @backend.ids(@combinations, :any, :thing) }.should < 0.0001
    #   end
    # end
  end

end