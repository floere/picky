# encoding: utf-8

require 'spec_helper'

describe 'Realtime Indexing' do
  class Book
    attr_reader :id, :title, :author

    def initialize(id, title, author)
      @id, @title, @author = id, title, author
    end
  end

  Picky::Index.new(:books) do
    category :title
    category :author, similarity: Picky::Generators::Similarity::DoubleMetaphone.new(3)
  end

  symbol_keys_index = Picky::Index.new(:books) do
    symbol_keys true

    category :title
    category :author, similarity: Picky::Generators::Similarity::DoubleMetaphone.new(3)
  end

  [symbol_keys_index].each do |index|
    context 'default index' do
      before(:each) { index.clear }
      let(:books) { Picky::Search.new index }

      before(:each) do
        index.add Book.new(1, 'Title', 'Author')
      end

      context 'dumping and loading' do
        it "doesn't find books anymore after dumping and loading and updating" do
          index.replace Book.new(2, 'Title New', 'Author New')

          books.search('title').ids.should == [2, 1]

          index.dump
          index.load
          index.build_realtime_mapping

          index.replace Book.new(2, 'Blah New', 'Author New')

          books.search('title').ids.should == [1]
        end
      end

      context 'single category updating' do
        it 'finds the first entry' do
          books.search('title:Titl').ids.should == [1]
        end

        it 'allows removing a single category and leaving the others alone' do
          index[:title].remove 1

          books.search('Title').ids.should == []
          books.search('Author').ids.should == [1]
        end

        it 'allows adding a single category and leaving the others alone' do
          index[:title].add Book.new(2, 'Newtitle', 'Newauthor')

          books.search('Title').ids.should == [1]
          books.search('Newtitle').ids.should == [2]

          books.search('Author').ids.should == [1]
          books.search('Newauthor').ids.should == []
        end

        it 'allows replacing a single category and leaving the others alone' do
          index[:title].replace Book.new(1, 'Replaced', 'Notindexed')

          books.search('Title').ids.should == []
          books.search('Replaced').ids.should == [1]

          books.search('Notindexed').ids.should == []
          books.search('Author').ids.should == [1]
        end
      end

      context 'with partial' do
        it 'finds the first entry' do
          books.search('Titl').ids.should == [1]
        end

        it 'allows removing something' do
          index.remove 1
        end
        it 'is not findable anymore after removing' do
          books.search('Titl').ids.should == [1]

          index.remove 1

          books.search('Titl').ids.should == []
        end

        it 'allows adding something' do
          index.add Book.new(2, 'Title2', 'Author2')
        end
        it 'is findable after adding' do
          books.search('Titl').ids.should == [1]

          index.add Book.new(2, 'Title New', 'Author New')

          books.search('Titl').ids.should == [2, 1]
        end
        it 'will not have duplicate result from adding something twice' do
          books.search('Titl').ids.should == [1]

          index.add Book.new(2, 'Title New', 'Author New')
          index.add Book.new(2, 'New Title', 'New Author')
          index.add Book.new(2, 'Title New', 'Author New')

          books.search('Titl').ids.should == [2, 1]
        end

        it 'allows replacing something' do
          index.replace Book.new(1, 'Title New', 'Author New')
        end
        it 'is findable after replacing' do
          books.search('Ne').ids.should == []

          index.replace Book.new(1, 'Title New', 'Author New')

          books.search('Ne').ids.should == [1, 1]
        end
        it 'handles more complex cases' do
          books.search('Ne').ids.should == []

          index.replace Book.new(1, 'Title New', 'Author New')

          books.search('title:Ne').ids.should == [1]
        end
        it 'handles more complex cases' do
          index.remove 1

          books.search('Titl').ids.should == []

          index.replace Book.new(1, 'Title New', 'Author New')

          books.search('title:Ne').ids.should == [1]
        end
        it 'does not unnecessarily change the position if a category already contains it (not true anymore)' do
          books.search('title:Title').ids.should == [1]

          index.add Book.new(2, 'Title New', 'Author New')

          books.search('title:Title').ids.should == [2, 1]

          index.replace Book.new(1, 'Title', 'Author')

          books.search('title:Title').ids.should == [1, 2]
        end
      end

      context 'non-partial' do
        it 'finds the first entry' do
          books.search('Titl').ids.should == [1]
        end

        it 'allows removing something' do
          index.remove 1
        end
        it 'is not findable anymore after removing' do
          books.search('Titl').ids.should == [1]

          index.remove 1

          books.search('Titl').ids.should == []
        end

        it 'allows adding something' do
          index.add Book.new(2, 'Title2', 'Author2')
        end
        it 'is findable after adding' do
          books.search('Titl').ids.should == [1]

          index.add Book.new(2, 'Title New', 'Author New')

          books.search('Titl').ids.should == [2, 1]
        end

        it 'allows replacing something' do
          index.replace Book.new(1, 'Title New', 'Author New')
        end
        it 'is findable after replacing' do
          books.search('Ne').ids.should == []

          index.replace Book.new(1, 'Title New', 'Author New')

          books.search('Ne').ids.should == [1, 1]
        end
        it 'handles more complex cases' do
          books.search('Ne').ids.should == []

          index.replace Book.new(1, 'Title New', 'Author New')

          books.search('title:Ne').ids.should == [1]
        end
        it 'handles more complex cases' do
          index.remove 1

          books.search('Titl').ids.should == []

          index.replace Book.new(1, 'Title New', 'Author New')

          books.search('title:Ne').ids.should == [1]
        end
      end

      context 'similarity' do
        it 'finds the first entry' do
          books.search('Authr~').ids.should == [1]
        end

        it 'allows removing something' do
          index.remove 1
        end
        it 'is not findable anymore after removing' do
          books.search('Authr~').ids.should == [1]

          index.remove 1

          books.search('Authr~').ids.should == []
        end

        it 'allows adding something' do
          index.add Book.new(2, 'Title2', 'Author2')
        end
        it 'is findable after adding' do
          books.search('Authr~').ids.should == [1]

          index.add Book.new(2, 'Title New', 'Author New')

          books.search('Authr~').ids.should == [2, 1]
        end

        it 'allows replacing something' do
          index.replace Book.new(1, 'Title New', 'Author New')
        end
        it 'is findable after replacing' do
          books.search('Nuw~').ids.should == []

          index.replace Book.new(1, 'Title New', 'Author New')

          books.search('Nuw~').ids.should == [1]
        end
        it 'handles more complex cases' do
          books.search('Now~').ids.should == []

          index.replace Book.new(1, 'Title New', 'Author New')

          books.search('author:Now~').ids.should == [1]
        end
        it 'handles more complex cases' do
          index.remove 1

          books.search('Athr~').ids.should == []

          index.replace Book.new(1, 'Title New', 'Author New')

          books.search('author:Athr~').ids.should == [1]
        end
        it 'handles more complex cases' do
          books.search('Athr~').ids.should == [1]

          index.replace Book.new(2, 'Title New', 'Author New')
          index.add Book.new(3, 'TTL', 'AUTHR')

          # Note: [2, 1] are in one allocation, [3] in the other.
          #
          books.search('author:Athr~').ids.should == [2, 1, 3]
        end
      end
    end
  end

  context 'index with key_format :to_sym' do
    let(:index) do
      Picky::Index.new(:books) do
        key_format :to_sym

        category :title
        category :author, similarity: Picky::Generators::Similarity::DoubleMetaphone.new(3)
      end
    end
    let(:books) { Picky::Search.new index }

    before(:each) do
      index.add Book.new('one', 'Title', 'Author')
    end

    context 'single category updating' do
      it 'finds the first entry' do
        books.search('title:Titl').ids.should == [:one]
      end

      it 'allows removing a single category and leaving the others alone' do
        index[:title].remove 'one'

        books.search('Title').ids.should == []
        books.search('Author').ids.should == [:one]
      end

      it 'allows adding a single category and leaving the others alone' do
        index[:title].add Book.new('two', 'Newtitle', 'Newauthor')

        books.search('Title').ids.should == [:one]
        books.search('Newtitle').ids.should == [:two]

        books.search('Author').ids.should == [:one]
        books.search('Newauthor').ids.should == []
      end

      it 'allows replacing a single category and leaving the others alone' do
        index[:title].replace Book.new('one', 'Replaced', 'Notindexed')

        books.search('Title').ids.should == []
        books.search('Replaced').ids.should == [:one]

        books.search('Notindexed').ids.should == []
        books.search('Author').ids.should == [:one]
      end
    end

    context 'with partial' do
      it 'finds the first entry' do
        books.search('Titl').ids.should == [:one]
      end

      it 'allows removing something' do
        index.remove 'one'
      end
      it 'is not findable anymore after removing' do
        books.search('Titl').ids.should == [:one]

        index.remove 'one'

        books.search('Titl').ids.should == []
      end

      it 'allows adding something' do
        index.add Book.new('two', 'Title2', 'Author2')
      end
      it 'is findable after adding' do
        books.search('Titl').ids.should == [:one]

        index.add Book.new('two', 'Title New', 'Author New')

        books.search('Titl').ids.should == [:two, :one]
      end

      it 'allows replacing something' do
        index.replace Book.new('one', 'Title New', 'Author New')
      end
      it 'is findable after replacing' do
        books.search('Ne').ids.should == []

        index.replace Book.new('one', 'Title New', 'Author New')

        books.search('Ne').ids.should == [:one, :one]
      end
      it 'handles more complex cases' do
        books.search('Ne').ids.should == []

        index.replace Book.new('one', 'Title New', 'Author New')

        books.search('title:Ne').ids.should == [:one]
      end
      it 'handles more complex cases' do
        index.remove 'one'

        books.search('Titl').ids.should == []

        index.replace Book.new('one', 'Title New', 'Author New')

        books.search('title:Ne').ids.should == [:one]
      end
    end

    context 'non-partial' do
      it 'finds the first entry' do
        books.search('Titl').ids.should == [:one]
      end

      it 'allows removing something' do
        index.remove 'one'
      end
      it 'is not findable anymore after removing' do
        books.search('Titl').ids.should == [:one]

        index.remove :one

        books.search('Titl').ids.should == []
      end

      it 'allows adding something' do
        index.add Book.new('two', 'Title2', 'Author2')
      end
      it 'is findable after adding' do
        books.search('Titl').ids.should == [:one]

        index.add Book.new('two', 'Title New', 'Author New')

        books.search('Titl').ids.should == [:two, :one]
      end

      it 'allows replacing something' do
        index.replace Book.new('one', 'Title New', 'Author New')
      end
      it 'is findable after replacing' do
        books.search('Ne').ids.should == []

        index.replace Book.new('one', 'Title New', 'Author New')

        books.search('Ne').ids.should == [:one, :one]
      end
      it 'handles more complex cases' do
        books.search('Ne').ids.should == []

        index.replace Book.new('one', 'Title New', 'Author New')

        books.search('title:Ne').ids.should == [:one]
      end
      it 'handles more complex cases' do
        index.remove 'one'

        books.search('Titl').ids.should == []

        index.replace Book.new('one', 'Title New', 'Author New')

        books.search('title:Ne').ids.should == [:one]
      end
    end

    context 'similarity' do
      it 'finds the first entry' do
        books.search('Authr~').ids.should == [:one]
      end

      it 'allows removing something' do
        index.remove 'one'
      end
      it 'is not findable anymore after removing' do
        books.search('Authr~').ids.should == [:one]

        index.remove 'one'

        books.search('Authr~').ids.should == []
      end

      it 'allows adding something' do
        index.add Book.new('two', 'Title2', 'Author2')
      end
      it 'is findable after adding' do
        books.search('Authr~').ids.should == [:one]

        index.add Book.new('two', 'Title New', 'Author New')

        books.search('Authr~').ids.should == [:two, :one]
      end

      it 'allows replacing something' do
        index.replace Book.new('one', 'Title New', 'Author New')
      end
      it 'is findable after replacing' do
        books.search('Nuw~').ids.should == []

        index.replace Book.new('one', 'Title New', 'Author New')

        books.search('Nuw~').ids.should == [:one]
      end
      it 'handles more complex cases' do
        books.search('Now~').ids.should == []

        index.replace Book.new('one', 'Title New', 'Author New')

        books.search('author:Now~').ids.should == [:one]
      end
      it 'handles more complex cases' do
        index.remove 'one'

        books.search('Athr~').ids.should == []

        index.replace Book.new('one', 'Title New', 'Author New')

        books.search('author:Athr~').ids.should == [:one]
      end
      it 'handles more complex cases' do
        books.search('Athr~').ids.should == [:one]

        index.replace Book.new('two', 'Title New', 'Author New')
        index.add Book.new('three', 'TTL', 'AUTHR')

        # Note: Allocations are [:two, :one], then [:three].
        #
        books.search('author:Athr~').ids.should == [:two, :one, :three]
      end
    end
  end

  context 'with Redis backend' do
    let(:index) do
      Picky::Index.new(:books) do
        backend Picky::Backends::Redis.new(realtime: true)
        key_format :to_s
        category :title
        category :author, similarity: Picky::Generators::Similarity::DoubleMetaphone.new(3)
      end
    end
    let(:books) { Picky::Search.new index }

    before(:each) do
      index.add Book.new('one', 'Title', 'Author')
    end

    context 'single category updating' do
      it 'finds the first entry' do
        books.search('title:Titl').ids.should == ['one']
      end

      it 'finds the first entry' do
        books.search('author:author title:Titl').ids.should == ['one']
      end

      it 'finds the first entry' do
        books.search('Author Titl').ids.should == ['one']
      end

      it 'finds the first entry the second time, too' do
        books.search('author:author title:Titl')

        books.search('author:author title:Titl').ids.should == ['one']
      end

      it 'finds the first entry the second time, even if the Redis script cache is flushed' do
        books.search('author:author title:Titl')

        books.search('author:author title:Titl').ids.should == ['one']

        index.backend.client.script 'flush'

        books.search('author:author title:Titl').ids.should == ['one']
      end

      it 'allows removing a single category and leaving the others alone' do
        index[:title].remove 'one'

        books.search('Title').ids.should == []
        books.search('Author').ids.should == ['one']
      end

      it 'allows adding a single category and leaving the others alone' do
        index[:title].add Book.new('two', 'Newtitle', 'Newauthor')

        books.search('Title').ids.should == ['one']
        books.search('Newtitle').ids.should == ['two']

        books.search('Author').ids.should == ['one']
        books.search('Newauthor').ids.should == []
      end

      it 'allows replacing a single category and leaving the others alone' do
        index[:title].replace Book.new('one', 'Replaced', 'Notindexed')

        books.search('Title').ids.should == []
        books.search('Replaced').ids.should == ['one']

        books.search('Notindexed').ids.should == []
        books.search('Author').ids.should == ['one']
      end
    end

    context 'with partial' do
      it 'finds the first entry' do
        books.search('Titl').ids.should == ['one']
      end

      it 'allows removing something' do
        index.remove 'one'
      end
      it 'is not findable anymore after removing' do
        books.search('Titl').ids.should == ['one']

        index.remove 'one'

        books.search('Titl').ids.should == []
      end

      it 'allows adding something' do
        index.add Book.new('two', 'Title2', 'Author2')
      end
      it 'is findable after adding' do
        books.search('Titl').ids.should == ['one']

        index.add Book.new('two', 'Title New', 'Author New')

        books.search('Titl').ids.should == %w[two one]
      end

      it 'allows replacing something' do
        index.replace Book.new('one', 'Title New', 'Author New')
      end
      it 'is findable after replacing' do
        books.search('Ne').ids.should == []

        index.replace Book.new('one', 'Title New', 'Author New')

        books.search('Ne').ids.should == %w[one one]
      end
      it 'handles more complex cases' do
        books.search('Ne').ids.should == []

        index.replace Book.new('one', 'Title New', 'Author New')

        books.search('title:Ne').ids.should == ['one']
      end
      it 'handles more complex cases' do
        index.remove 'one'

        books.search('Titl').ids.should == []

        index.replace Book.new('one', 'Title New', 'Author New')

        books.search('title:Ne').ids.should == ['one']
      end
    end

    context 'non-partial' do
      it 'finds the first entry' do
        books.search('Titl').ids.should == ['one']
      end

      it 'allows removing something' do
        index.remove 'one'
      end
      it 'is not findable anymore after removing' do
        books.search('Titl').ids.should == ['one']

        index.remove :one

        books.search('Titl').ids.should == []
      end

      it 'allows adding something' do
        index.add Book.new('two', 'Title2', 'Author2')
      end
      it 'is findable after adding' do
        books.search('Titl').ids.should == ['one']

        index.add Book.new('two', 'Title New', 'Author New')

        books.search('Titl').ids.should == %w[two one]
      end

      it 'allows replacing something' do
        index.replace Book.new('one', 'Title New', 'Author New')
      end
      it 'is findable after replacing' do
        books.search('Ne').ids.should == []

        index.replace Book.new('one', 'Title New', 'Author New')

        books.search('Ne').ids.should == %w[one one]
      end
      it 'handles more complex cases' do
        books.search('Ne').ids.should == []

        index.replace Book.new('one', 'Title New', 'Author New')

        books.search('title:Ne').ids.should == ['one']
      end
      it 'handles more complex cases' do
        index.remove 'one'

        books.search('Titl').ids.should == []

        index.replace Book.new('one', 'Title New', 'Author New')

        books.search('title:Ne').ids.should == ['one']
      end
    end

    context 'similarity' do
      it 'finds the first entry' do
        books.search('Authr~').ids.should == ['one']
      end

      it 'allows removing something' do
        index.remove 'one'
      end
      it 'is not findable anymore after removing' do
        books.search('Authr~').ids.should == ['one']

        index.remove 'one'

        books.search('Authr~').ids.should == []
      end

      it 'allows adding something' do
        index.add Book.new('two', 'Title2', 'Author2')
      end
      it 'is findable after adding' do
        books.search('Authr~').ids.should == ['one']

        index.add Book.new('two', 'Title New', 'Author New')

        books.search('Authr~').ids.should == %w[two one]
      end

      it 'allows replacing something' do
        index.replace Book.new('one', 'Title New', 'Author New')
      end
      it 'is findable after replacing' do
        books.search('Nuw~').ids.should == []

        index.replace Book.new('one', 'Title New', 'Author New')

        books.search('Nuw~').ids.should == ['one']
      end
      it 'handles more complex cases' do
        books.search('Now~').ids.should == []

        index.replace Book.new('one', 'Title New', 'Author New')

        books.search('author:Now~').ids.should == ['one']
      end
      it 'handles more complex cases' do
        index.remove 'one'

        books.search('Athr~').ids.should == []

        index.replace Book.new('one', 'Title New', 'Author New')

        books.search('author:Athr~').ids.should == ['one']
      end
      it 'handles more complex cases' do
        books.search('Athr~').ids.should == ['one']

        index.replace Book.new('two', 'Title New', 'Author New')
        index.add Book.new('three', 'TTL', 'AUTHR')

        # Note: Allocations are [:two, :one], then [:three].
        #
        books.search('author:Athr~').ids.should == %w[two one three]
      end
    end
  end
end
