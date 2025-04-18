require 'spec_helper'
require_relative '../app' # Only needed when running this spec alone.
require_relative '../../../client/lib/picky-client/spec'

describe BookSearch do
  before(:all) do
    Picky::Indexes.index
    Picky::Indexes.load
  end

  let(:books)           { Picky::TestClient.new(described_class, path: '/books')          }
  let(:books_ignoring)  { Picky::TestClient.new(described_class, path: '/books_ignoring') }
  let(:book_each)       { Picky::TestClient.new(described_class, path: '/book_each')      }
  let(:csv)             { Picky::TestClient.new(described_class, path: '/csv')            }
  let(:redis)           { Picky::TestClient.new(described_class, path: '/redis')          }
  let(:sym)             { Picky::TestClient.new(described_class, path: '/sym')            }
  let(:geo)             { Picky::TestClient.new(described_class, path: '/geo')            }
  let(:simple_geo)      { Picky::TestClient.new(described_class, path: '/simple_geo')     }
  let(:indexing)        { Picky::TestClient.new(described_class, path: '/indexing')       }
  let(:memory_changing) { Picky::TestClient.new(described_class, path: '/memory_changing') }
  let(:redis_changing)  { Picky::TestClient.new(described_class, path: '/redis_changing') }
  let(:file)            { Picky::TestClient.new(described_class, path: '/file')           }
  let(:japanese)        { Picky::TestClient.new(described_class, path: '/japanese')       }
  # let(:backends)        { Picky::TestClient.new(described_class, path: '/backends')       }
  let(:nonstring)       { Picky::TestClient.new(described_class, path: '/nonstring')      }
  let(:partial)         { Picky::TestClient.new(described_class, path: '/partial')        }
  let(:sqlite)          { Picky::TestClient.new(described_class, path: '/sqlite')         }
  let(:commas)          { Picky::TestClient.new(described_class, path: '/commas')         }

  describe 'dump' do
    it 'simply works' do
      Thing = Struct.new :id, :name

      index = Picky::Index.new :dump_test do
        category :name
      end

      index.replace Thing.new(1, 'Picky')
      index.replace Thing.new(2, 'Phony')

      index.dump
    end
  end

  it 'can generate a single index category without failing' do
    book_each_index = Picky::Indexes[:book_each][:title]
    book_each_index.prepare
    book_each_index.cache
  end

  it 'is has the right amount of results' do
    expect(csv.search('alan').total).to eq 3
  end

  it 'has correctly structured in-detail results' do
    expect(csv.search('alan').allocations).to eq [
      ['Books', 6.693, 2, [%w[author alan alan]], [259, 307]],
      ['Books', 0.0,   1, [%w[title alan alan]], [449]]
    ]
  end

  # Multicategory search.
  #
  it 'has the right categories' do
    expect(csv.search('title,author:alan').ids).to eq [259, 307, 449]
  end
  it 'simply ignores extraneous categories' do
    expect(csv.search('title,author,quackquack:alan').ids).to eq [259, 307, 449]
  end
  it 'will not return anything on wrong categories' do
    expect(csv.search('quack,moo,derp:alan').ids).to eq []
  end

  it 'has the right categories' do
    expect(csv.search('alan')).to have_categories(['author'], ['title'])
  end
  it 'has the right categories' do
    expect(csv.search('a')).to have_categories(['author'], ['title'], ['subjects'], ['publisher'])
  end

  it 'finds the same after reloading' do
    expect(csv.search('soledad human').ids).to eq [72]
    Picky.logger.info 'Reloading'
    Picky::Indexes.load
    expect(csv.search('soledad human').ids).to eq [72]
  end

  it 'can handle changing data with a Memory backend' do
    expect(memory_changing.search('entry').ids).to eq [1, 2, 3]

    new_source = [
      # ChangingItem.new("1", 'first entry'), # Removed.
      ChangingItem.new('2', 'second entry'),
      ChangingItem.new('3', 'third entry'),
      ChangingItem.new('4', 'fourth entry') # Added.
    ]
    Picky::Indexes[:memory_changing].source new_source
    Picky::Indexes[:memory_changing].index
    Picky::Indexes[:memory_changing].load

    expect(memory_changing.search('entry').ids).to eq [2, 3, 4]

    # TODO.
    #
    # Picky::Indexes[:memory_changing].remove 3
    #
    # expect(memory_changing.search('entry').ids).to eq [2, 4]
  end

  it 'can handle changing data with a Redis backend' do
    expect(redis_changing.search('entry').ids).to eq %w[1 2 3]

    new_source = [
      # ChangingItem.new("1", 'first entry'), # Removed.
      ChangingItem.new('2', 'second entry'),
      ChangingItem.new('3', 'third entry'),
      ChangingItem.new('4', 'fourth entry') # Added.
    ]
    Picky::Indexes[:redis_changing].source new_source
    Picky::Indexes[:redis_changing].index
    Picky::Indexes[:redis_changing].load

    expect(redis_changing.search('entry').ids).to eq %w[2 3 4]

    # TODO.
    #
    # Picky::Indexes[:redis_changing].remove "3"
    #
    # expect(redis_changing.search('entry').ids).to eq ["2", "4"]
  end

  # Breakage. As reported by Jason.
  #
  # TODO Should it find it in [2, 2]?
  #
  it 'finds with specific id' do
    expect(books.search('id:"2"').ids).to eq [2]
  end
  # # As reported by Simon.
  # #
  # it 'finds a location' do
  #   @underscore.search('some_place:Zuger some_place:See')).to eq []
  # end

  # Respects ids param and offset.
  #
  it { expect(csv.search('title:le* title:hystoree~', ids: 2, offset: 0).ids).to eq [4, 250] }
  it { expect(csv.search('title:le* title:hystoree~', ids: 1, offset: 1).ids).to eq [250] }

  # Standard tests.
  #
  it { expect(csv.search('soledad human').ids).to eq [72] }
  it { expect(csv.search('first three minutes weinberg').ids).to eq [1] }

  # Standard tests with ignoring unassigned.
  #
  it { expect(books_ignoring.search('soledad human quack').ids).to eq [72] }
  it { expect(books_ignoring.search('first quack three quack minutes weinberg quack').ids).to eq [1] }

  # "Symbol" keys.
  #
  it { expect(sym.search('key').ids).to eq %w[a b c d e f] }
  it { expect(sym.search('keydkey').ids).to eq ['d'] }
  it { expect(sym.search('"keydkey"').ids).to eq ['d'] }

  # Complex cases.
  #
  it { expect(csv.search('title:le* title:hystoree~').ids).to eq [4, 250, 428] }
  it { expect(csv.search('hystori~ author:ferg').ids).to eq [] }
  it { expect(csv.search('hystori~ author:fergu').ids).to eq [4] }
  it { expect(csv.search('hystori~ author:fergus').ids).to eq [4] }
  it { expect(csv.search('author:fergus').ids).to eq [4] }

  # Partial searches.
  #
  it { expect(csv.search('gover* systems').ids).to eq [7] }
  it {
    expect(csv.search('a*').ids).to eq [4, 7, 8, 80, 117, 119, 125, 132, 168, 176, 184, 222, 239, 242, 333, 346, 352, 361,
                                        364, 380]
  }
  it { expect(csv.search('a* b* c* d* f').ids).to eq [110, 416] }
  it { expect(csv.search('1977').ids).to eq [86, 394] }

  # Similarity.
  #
  it { expect(csv.search('hystori~ leeward').ids).to eq [4] }
  it { expect(csv.search('strutigic~').ids).to eq [7, 398, 414] }
  it {
    expect(csv.search('guvurnance~').ids).to eq [126, 181, 198, 263, 298, 324, 419, 22]
  } # TODO: 7 should be in the result set.
  it { expect(csv.search('strutigic~ guvurnance~').ids).to eq [7] }
  it { expect(csv.search('strategic~ governance~').ids).to eq [] } # Does not find itself.

  # Qualifiers.
  #
  it { expect(csv.search('title:history author:fergus').ids).to eq [4] }

  # Splitting.
  #
  it { expect(csv.search('history/fergus&history/history&fergus').ids).to eq [4, 4, 4, 4, 4, 4, 4, 4] }

  # Character Removal.
  #
  it { expect(csv.search("'(history)' '(fergus)'").ids).to eq [4, 4] }

  # Contraction.
  #
  # it_should_find_ids_in_csv ""

  # Stopwords.
  #
  it { expect(csv.search('and the history or fergus').ids).to eq [4, 4] }
  it { expect(csv.search('and the or on of in is to from as at an history fergus').ids).to eq [4, 4] }

  # Normalization.
  #
  it { expect(csv.search('Deoxyribonucleic Acid').ids).to eq [] }
  it { expect(csv.search('800 dollars').ids).to eq [] }

  # Remove after splitting.
  #
  it { expect(csv.search('his|tory fer|gus').ids).to eq [4, 4] }

  # Character Substitution.
  #
  it { expect(csv.search('hïstôry educåtioñ fërgus').ids).to eq [4, 4, 4, 4] }

  # Token Rejection.
  #
  it { expect(csv.search('amistad').ids).to eq [] }

  # Breakage.
  #
  it { expect(csv.search('%@{*^$!*$$^!&%!@%#!%#(#!@%#!#!)}').ids).to eq [] }
  it {
    expect(csv.search('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa').ids).to eq []
  }
  it { expect(csv.search('glorfgnorfblorf').ids).to eq [] }

  # Range based area search. Memory.
  #
  it {
    expect(simple_geo.search('north1:47.41 east1:8.55').ids).to eq [1481, 5014, 5015, 5016, 10_576, 10_717, 17_777,
                                                                    17_999]
  }

  # Geo based area search.
  #
  it {
    expect(geo.search('north:47.41 east:8.55').ids).to eq [1481, 5010, 5011, 5012, 5013, 5014, 5015, 5016, 5017, 5059,
                                                           9110, 10_347, 10_576, 10_717, 10_879, 17_777, 17_955, 18_038]
  }

  # Redis.
  #
  it { expect(redis.search('soledad human').ids).to eq ['72'] }
  it { expect(redis.search('first three minutes weinberg').ids).to eq ['1'] }
  it { expect(redis.search('gover* systems').ids).to eq ['7'] }
  it {
    expect(redis.search('a*').ids).to eq %w[4 7 8 80 117 119 125 132 168 176 184 222 239 242 333 346 352 361 364 380]
  }
  it { expect(redis.search('a* b* c* d* f').ids).to eq %w[110 416] }
  it { expect(redis.search('1977').ids).to eq %w[86 394] }

  # Categorization.
  #
  it { expect(csv.search('t:religion').ids).to eq csv.search('title:religion').ids }
  it { expect(csv.search('title:religion').ids).to_not eq csv.search('subject:religion').ids }

  # Wrong categorization.
  #
  # From 2.5.0 on, Picky does not remove wrong categories anymore. Wrong categories return zero results.
  #
  it { expect(csv.search('gurk:religion').ids).to eq [] }

  # Index-specific tokenizer.
  #
  it 'does not find abc' do
    expect(indexing.search('human perception').ids).to eq []
  end
  it 'does find without a or b or c' do
    expect(indexing.search('humn pereption').ids).to eq [72]
  end

  # Boosting.
  #
  # it 'boosts the right combination' do
  #   expect(csv.search('history').ids).to eq [4, 5, 6, 7, 10, 16, 21, 23, 24, 37, 40, 43, 47, 53, 55, 59, 68, 76, 85, 90]
  # end

  # Downcasing.
  #
  it { expect(csv.search('history fergus').ids).to eq [4, 4] }
  it { expect(csv.search('HISTORY FERGUS').ids).to eq [] }
  it { expect(csv.search('history AND OR fergus').ids).to eq [4, 4] }

  # File based.
  #
  it { expect(file.search('first').ids).to eq [1] }
  it { expect(file.search('entry').ids).to eq [1, 2, 3] }
  it { expect(file.search('entry first').ids).to eq [1] }

  # Infix partial.
  #
  it { expect(file.search('ntr* rst*').ids).to eq [1] }

  # Japanese characters (UTF-8).
  #
  it { expect(japanese.search('日本語').ids).to eq [1] }
  it { expect(japanese.search('にほんご').ids).to eq [1] }
  it { expect(japanese.search('食べる').ids).to eq [2] }
  it { expect(japanese.search('たべる').ids).to eq [2] }
  #
  # Partial.
  #
  it { expect(japanese.search('日').ids).to eq [1] }

  # Different tokenizer.
  #
  it { expect(nonstring.search('moo zap').ids).to eq [2] }

  # Partial options.
  #
  it { expect(partial.search('substring:oct').ids).to eq [] }
  it { expect(partial.search('substring:octo').ids).to eq [] }
  it { expect(partial.search('substring:octop').ids).to eq [1] }
  it { expect(partial.search('substring:octopu').ids).to eq [1] }
  it { expect(partial.search('substring:octopus').ids).to eq [1] }
  it { expect(partial.search('substring:octopuss').ids).to eq [] }
  it { expect(partial.search('substring:octopussy').ids).to eq [] }

  it { expect(partial.search('postfix:oct').ids).to eq [] }
  it { expect(partial.search('postfix:octo').ids).to eq [] }
  it { expect(partial.search('postfix:octop').ids).to eq [1] }
  it { expect(partial.search('postfix:octopu').ids).to eq [1] }
  it { expect(partial.search('postfix:octopus').ids).to eq [1] }
  it { expect(partial.search('postfix:octopuss').ids).to eq [1] }
  it { expect(partial.search('postfix:octopussy').ids).to eq [1] }

  it { expect(partial.search('infix:c').ids).to eq [1, 2] }
  it { expect(partial.search('infix:br').ids).to eq [2] }
  it { expect(partial.search('infix:cad').ids).to eq [2] }

  it { expect(partial.search('none:octopussy').ids).to eq [1] }
  it { expect(partial.search('none:abracadabra').ids).to eq [2] }

  # Search#ignore option.
  #
  # TODO Removed in 4.9+. Reintroduce!
  #
  it { expect(book_each.search('alan history').ids).to eq %w[259 307] } # Ignores History or Alan in title.

  # SQLite backend.
  #
  it { expect(sqlite.search('hello sqlite').ids).to eq [1] }

  # Commas in ids.
  #
  it { expect(commas.search('text').ids).to eq ['a,b', 'c,d'] }

  # Database index reloading.
  #
  it 'can handle changing data with a Memory backend with a non-each DB source' do
    # expect(books.search('1977').ids).to eq [86, 394]

    # Some webapp adds a book.
    #
    added_book = Book.create! title: 'Some Title',
                              author: 'Tester Mc Testy',
                              isbn: '1231231231231',
                              year: '1977'
    expected_id = added_book.id

    Picky::Indexes[:books].index
    Picky::Indexes[:books].load

    # We can destroy the book now as it has been indexed.
    #
    added_book.destroy

    expect(books.search('1977').ids).to eq [86, 394, expected_id]
  end

  # Database index reloading.
  #
  it 'can handle changing data with a Memory backend with an each DB source' do
    expect(book_each.search('1977').ids).to eq %w[86 394]

    # Some webapp adds a book.
    #
    added_book = Book.create! title: 'Some Title',
                              author: 'Tester Mc Testy',
                              isbn: '1231231231231',
                              year: 1977
    expected_id = added_book.id

    Picky::Indexes[:book_each].index
    Picky::Indexes[:book_each].load

    # We can destroy the book now as it has been indexed.
    #
    added_book.destroy

    expect(book_each.search('1977').ids).to eq ['86', '394', expected_id.to_s]
  end
end
