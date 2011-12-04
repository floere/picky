require 'spec_helper'

describe Picky::Query::IndexesCheck do

  describe 'check_backend_types' do
    backends = [
      Picky::Backends::Memory.new,
      Picky::Backends::File.new,
      Picky::Backends::SQLite.new,
      Picky::Backends::Redis.new
    ]
    backends.each do |backend|
      it 'does not raise on the same type' do
        index = stub :index, backend: backend
        described_class.check_backends [index, index]
      end
    end

    # Test all combinations
    #
    combinations = backends.combination 2
    combinations.each do |backend1, backend2|
      let(:index1) { stub :index1, backend: backend1 }
      let(:index2) { stub :index2, backend: backend2 }
      it 'raises on multiple types' do
        expect do
          described_class.check_backends [index1, index2]
        end.to raise_error(Picky::Query::DifferentBackendsError)
      end
      it 'raises with the right message on multiple types' do
        expect do
          described_class.check_backends [index1, index2]
        end.to raise_error("Currently it isn't possible to mix Indexes with backends #{index1.backend.class} and #{index2.backend.class} in the same Search instance.")
      end
    end
    combinations = backends.combination 3
    combinations.each do |backend1, backend2, backend3|
      let(:index1) { stub :index1, backend: backend1 }
      let(:index2) { stub :index2, backend: backend2 }
      let(:index3) { stub :index2, backend: backend3 }
      it 'raises on multiple types' do
        expect do
          described_class.check_backends [index1, index2, index3]
        end.to raise_error(Picky::Query::DifferentBackendsError)
      end
      it 'raises with the right message on multiple types' do
        expect do
          described_class.check_backends [index1, index2, index3]
        end.to raise_error("Currently it isn't possible to mix Indexes with backends #{index1.backend.class} and #{index2.backend.class} and #{index3.backend.class} in the same Search instance.")
      end
    end
  end

end