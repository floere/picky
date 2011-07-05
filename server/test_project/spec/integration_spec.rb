# coding: utf-8
#
require 'spec_helper'
require 'picky-client/spec'

describe BookSearch do

  before(:all) do
    Indexes.index_for_tests
    Indexes.load_from_cache
  end

  let(:books)           { Picky::TestClient.new(described_class, :path => '/books')           }
  let(:csv)             { Picky::TestClient.new(described_class, :path => '/csv')             }
  let(:redis)           { Picky::TestClient.new(described_class, :path => '/redis')           }
  let(:sym)             { Picky::TestClient.new(described_class, :path => '/sym')             }
  let(:geo)             { Picky::TestClient.new(described_class, :path => '/geo')             }
  let(:simple_geo)      { Picky::TestClient.new(described_class, :path => '/simple_geo')      }
  let(:indexing)        { Picky::TestClient.new(described_class, :path => '/indexing')        }
  let(:memory_changing) { Picky::TestClient.new(described_class, :path => '/memory_changing') }
  let(:redis_changing)  { Picky::TestClient.new(described_class, :path => '/redis_changing')  }
  
  it 'can generate a single index category without failing' do
    book_each_index = Indexes[:book_each][:title]
    book_each_index.prepare
    book_each_index.cache
  end
  
  it 'is has the right amount of results' do
    csv.search('alan').total.should == 3
  end

  it 'has correctly structured in-detail results' do
    csv.search('alan').allocations.should == [
      ["Books", 6.6899999999999995, 2, [["author", "alan", "alan"]], [259, 307]],
      ["Books", 0.0,                1, [["title",  "alan", "alan"]], [449]]
    ]
  end
  
  # Multicategory search.
  #
  it 'has the right categories' do
    csv.search('title,author:alan').ids.should == [259, 307, 449]
  end
  it 'simply ignores extraneous categories' do
    csv.search('title,author,quackquack:alan').ids.should == [259, 307, 449]
  end
  it 'will not return anything on wrong categories' do
    csv.search('quack,moo,derp:alan').ids.should == []
  end

  it 'has the right categories' do
    csv.search('alan').should have_categories(['author'], ['title'])
  end
  it 'has the right categories' do
    csv.search('a').should have_categories(['author'], ['title'], ['subjects'], ['publisher'])
  end

  it 'finds the same after reloading' do
    csv.search('soledad human').ids.should == [72]
    puts "Reloading the Indexes."
    Indexes.reload
    csv.search('soledad human').ids.should == [72]
  end
  
  it 'can handle changing data with a Memory backend' do
    memory_changing.search('entry').ids.should == [1, 2, 3]
    
    new_source = [
      # ChangingItem.new("1", 'first entry'), # Removed.
      ChangingItem.new("2", 'second entry'),
      ChangingItem.new("3", 'third entry'),
      ChangingItem.new("4", 'fourth entry') # Added.
    ]
    Indexes[:memory_changing].source new_source
    Indexes[:memory_changing].index
    Indexes[:memory_changing].reload
    
    memory_changing.search('entry').ids.should == [2, 3, 4]
  end
  
  it 'can handle changing data with a Redis backend' do
    redis_changing.search('entry').ids.should == ["1", "2", "3"]
    
    new_source = [
      # ChangingItem.new("1", 'first entry'), # Removed.
      ChangingItem.new("2", 'second entry'),
      ChangingItem.new("3", 'third entry'),
      ChangingItem.new("4", 'fourth entry') # Added.
    ]
    Indexes[:redis_changing].source new_source
    Indexes[:redis_changing].index
    Indexes[:redis_changing].reload
    
    redis_changing.search('entry').ids.should == ["2", "3", "4"]
  end

  # Breakage. As reported by Jason.
  #
  it 'finds with specific id' do
    books.search('id:"2"').ids.should == [2]
  end
  # # As reported by Simon.
  # #
  # it 'finds a location' do
  #   @underscore.search_with_text('some_place:Zuger some_place:See').should == []
  # end

  # Respects ids param and offset.
  #
  it { csv.search('title:le* title:hystoree~', :ids => 2, :offset => 0).ids.should == [4, 250] }
  it { csv.search('title:le* title:hystoree~', :ids => 1, :offset => 1).ids.should == [250] }

  # Standard tests.
  #
  it { csv.search('soledad human').ids.should == [72] }
  it { csv.search('first three minutes weinberg').ids.should == [1] }

  # "Symbol" keys.
  #
  it { sym.search('key').ids.should == ['a', 'b', 'c', 'd', 'e', 'f'] }
  it { sym.search('keydkey').ids.should == ['d'] }
  it { sym.search('"keydkey"').ids.should == ['d'] }

  # Complex cases.
  #
  it { csv.search('title:le* title:hystoree~').ids.should == [4, 250, 428] }
  it { csv.search('hystori~ author:ferg').ids.should == [] }
  it { csv.search('hystori~ author:fergu').ids.should == [4, 4] }
  it { csv.search('hystori~ author:fergus').ids.should == [4, 4] }
  it { csv.search('author:fergus').ids.should == [4] }

  # Partial searches.
  #
  it { csv.search('gover* systems').ids.should == [7] }
  it { csv.search('a*').ids.should == [4, 7, 8, 80, 117, 119, 125, 132, 168, 176, 184, 222, 239, 242, 333, 346, 352, 361, 364, 380] }
  it { csv.search('a* b* c* d* f').ids.should == [110, 416] }
  it { csv.search('1977').ids.should == [86, 394] }

  # Similarity.
  #
  it { csv.search('hystori~ leeward').ids.should == [4, 4] }
  it { csv.search('strutigic~ guvurnance~').ids.should == [7] }
  it { csv.search('strategic~ governance~').ids.should == [] } # Does not find itself.

  # Qualifiers.
  #
  it { csv.search('title:history author:fergus').ids.should == [4] }

  # Splitting.
  #
  it { csv.search('history/fergus&history/history&fergus').ids.should == [4, 4, 4, 4, 4, 4, 4, 4] }

  # Character Removal.
  #
  it { csv.search("'(history)' '(fergus)'").ids.should == [4, 4] }

  # Contraction.
  #
  # it_should_find_ids_in_csv ""

  # Stopwords.
  #
  it { csv.search("and the history or fergus").ids.should == [4, 4] }
  it { csv.search("and the or on of in is to from as at an history fergus").ids.should == [4, 4] }

  # Normalization.
  #
  it { csv.search('Deoxyribonucleic Acid').ids.should == [] }
  it { csv.search('800 dollars').ids.should == [] }

  # Remove after splitting.
  #
  it { csv.search("his|tory fer|gus").ids.should == [4, 4] }

  # Character Substitution.
  #
  it { csv.search("hïstôry educåtioñ fërgus").ids.should == [4, 4, 4, 4] }

  # Token Rejection.
  #
  it { csv.search('amistad').ids.should == [] }

  # Breakage.
  #
  it { csv.search("%@{*^$!*$$^!&%!@%#!%#(#!@%#!#!)}").ids.should == [] }
  it { csv.search("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa").ids.should == [] }
  it { csv.search("glorfgnorfblorf").ids.should == [] }

  # Range based area search. Memory.
  #
  it { simple_geo.search("north1:47.41 east1:8.55").ids.should == [1413, 10346, 10661, 10746, 10861] }

  # Geo based area search.
  #
  it { geo.search("north:47.41 east:8.55").ids.should == [1413, 5015, 9168, 10346, 10661, 10746, 10768, 10861] }

  # Redis.
  #
  it { redis.search('soledad human').ids.should == ['72'] }
  it { redis.search('first three minutes weinberg').ids.should == ['1'] }
  it { redis.search('gover* systems').ids.should == ['7'] }
  it { redis.search('a*').ids.should == ['4', '7', '8', '80', '117', '119', '125', '132', '168', '176', '184', '222', '239', '242', '333', '346', '352', '361', '364', '380'] }
  it { redis.search('a* b* c* d* f').ids.should == ['110', '416'] }
  it { redis.search('1977').ids.should == ['86', '394'] }

  # Categorization.
  #
  it { csv.search('t:religion').ids.should == csv.search('title:religion').ids }
  it { csv.search('title:religion').ids.should_not == csv.search('subject:religion').ids }
  
  # Wrong categorization.
  #
  # From 2.5.0 on, Picky does not remove wrong categories anymore. Wrong categories return zero results.
  #
  it { csv.search('gurk:religion').ids.should == [] }

  # Index-specific tokenizer.
  #
  it 'does not find abc' do
    indexing.search('human perception').ids.should == []
  end
  it 'does find without a or b or c' do
    indexing.search('humn pereption').ids.should == [72]
  end

  # Boosting.
  #
  # it 'boosts the right combination' do
  #   csv.search('history').ids.should == [4, 5, 6, 7, 10, 16, 21, 23, 24, 37, 40, 43, 47, 53, 55, 59, 68, 76, 85, 90]
  # end

  # Downcasing.
  #
  it { csv.search("history fergus").ids.should == [4, 4] }
  it { csv.search("HISTORY FERGUS").ids.should == [] }
  it { csv.search("history AND OR fergus").ids.should == [4, 4] }
  
  # Database index reloading.
  #
  it 'can handle changing data with a Memory backend with a DB source' do
    books.search('1977').ids.should == [86, 394]
    
    # Some webapp adds a book.
    #
    BookSearch::Book.establish_connection YAML.load(File.open('app/db.yml'))
    added_book = BookSearch::Book.create! title:  "Some Title",
                                          author: "Tester Mc Testy",
                                          isbn:   "1231231231231",
                                          year:   1977
    expected_id = added_book.id
    
    # TODO Remove this line and include take_snapshot cleanly in indexing.
    #
    Indexes[:books].take_snapshot # Works if this one is not commented.
    Indexes[:books].index
    Indexes[:books].reload
    
    # We can destroy the book now as it has been indexed.
    #
    added_book.destroy
    
    books.search('1977').ids.should == [86, 394, expected_id]
  end

end