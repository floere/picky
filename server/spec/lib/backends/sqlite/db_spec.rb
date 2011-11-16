require 'spec_helper'

require 'sqlite3'

describe Picky::Backends::Sqlite::DB do

  context 'hash-based indexes' do
    let(:db) { described_class.new 'some/cache/path/to/file' }

    describe 'dump' do
      it 'delegates to the given hash' do
        hash = stub :hash

        db.should_receive(:dump_sqlite).once.with hash

        db.dump hash
      end
    end

    describe 'dump_sqlite' do
      let(:client) { stub :client }
      before(:each) do
        db.stub! :db => client
      end
      it 'initializes the client' do
        client.stub! :execute

        db.should_receive(:lazily_initialize_client).once.with

        db.dump_sqlite Hash.new
      end
      it 'executes something' do
        db.stub! :lazily_initialize_client

        client.should_receive(:execute).at_least(1).times

        db.dump_sqlite Hash.new
      end
      it 'inserts keys and values' do
        db.stub! :lazily_initialize_client
        client.stub! :execute # We only want to test the insert statements.

        client.should_receive(:execute).once.with 'insert into key_value values (?,?)', 'a', '[1,2,3]'
        client.should_receive(:execute).once.with 'insert into key_value values (?,?)', 'b', '[4,5,6]'

        db.dump_sqlite :a => [1,2,3], :b => [4,5,6]
      end
    end

    describe 'load' do
      it 'returns a copy of itself' do
        db.load.should == db
      end
      it 'initializes the client' do
        db.should_receive(:lazily_initialize_client).once.with

        db.load
      end
    end

    describe 'empty' do
      it 'returns the container that is used for indexing' do
        db.empty.should == {}
      end
    end

    describe 'initial' do
      it 'is correct' do
        db.initial.should == {}
      end
    end

    describe 'to_s' do
      it 'returns the cache path with the default file extension' do
        db.to_s.should == 'Picky::Backends::Sqlite::DB(some/cache/path/to/file.sqlite3)'
      end
    end
  end

end
