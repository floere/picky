# encoding: utf-8
require 'spec_helper'

describe Picky::Scheduler do

  context 'default params' do
    let(:scheduler) { described_class.new }

    context 'without forking' do
      before(:each) do
        scheduler.stub fork?: false
      end
      context 'non-stubbed forking' do
        it 'works correctly' do
          scheduler.schedule { sleep 0.01 }
          scheduler.schedule { sleep 0.01 }
          scheduler.schedule { sleep 0.01 }
          scheduler.schedule { sleep 0.01 }
        end
        it 'works correctly' do
          called = 0

          scheduler.schedule { called += 1 }
          scheduler.schedule { called += 1 }
          scheduler.schedule { called += 1 }
          scheduler.schedule { called += 1 }

          called.should == 4
        end
      end
    end

    describe 'fork?' do
      context 'OS can fork' do
        it 'returns false' do
          scheduler.fork?.should be_falsy
        end
      end
      context 'OS cannot fork' do
        before(:each) do
          Process.stub fork: nil
        end
        it 'returns false' do
          scheduler.fork?.should be_falsy
        end
      end
    end
  end
  context 'default params' do
    let(:scheduler) { described_class.new parallel: true }

    context 'stubbed forking' do
      it 'works correctly' do
        scheduler.scheduler.should_receive(:schedule).exactly(4).times.and_yield

        scheduler.schedule { sleep 0.01 }
        scheduler.schedule { sleep 0.01 }
        scheduler.schedule { sleep 0.01 }
        scheduler.schedule { sleep 0.01 }
      end
      it 'works correctly' do
        scheduler.scheduler.should_receive(:schedule).at_least(1).and_yield

        called = 0

        scheduler.schedule { called += 1 }
        scheduler.schedule { called += 1 }
        scheduler.schedule { called += 1 }
        scheduler.schedule { called += 1 }

        called.should == 4
      end
    end

    describe 'fork?' do
      context 'OS can fork' do
        it 'returns true' do
          scheduler.fork?.should == true
        end
      end
      # context 'OS cannot fork' do
      #   before(:each) do
      #     Process.send :undef, :fork
      #   end
      #   it 'returns false' do
      #     scheduler.fork?.should == false
      #   end
      # end
    end
  end

end
