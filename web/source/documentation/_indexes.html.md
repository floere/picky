## Indexes{#indexes}

Indexes do three things:

* Define where the data comes from.
* Define how data is handled before it enters the index.
* Hold index categories.

### Types{#indexes-types}

Picky offers a choice of four index types:

* Memory: Saves its indexes in JSON on disk and loads them into memory.
* Redis: Saves its indexes in Redis.
* SQLite: Saves its indexes in rows of a SQLite DB.
* File: Saves its indexes in JSON in files.

This is how they look in code:

    books_memory_index = Index.new :books do
      # Configuration goes here.
    end

    books_redis_index = Index.new :books do
      backend Backends::Redis.new
      # Configuration goes here.
    end

Both save the preprocessed data from the data source in the `/index` directory so you can go look if the data is preprocessed correctly.

Indexes are then used in a `Search` interface.

Searching over one index:

    books = Search.new books_index

Searching over multiple indexes:

    media = Search.new books_index, dvd_index, mp3_index

The resulting ids should be from the same id space to be useful – or the ids should be exclusive, such that eg. a book id does not collide with a dvd id.

#### In-Memory / File-based{#indexes-types-memory}

The in-memory index saves its indexes as files transparently in the form of JSON files that reside in the `/index` directory.

When the server is started, they are loaded into memory. As soon as the server is stopped, the indexes are not in memory again.

Indexing regenerates the JSON index files and can be reloaded into memory, even in the running server (see below).

#### Redis{#indexes-types-redis}

The Redis index saves its indexes in the Redis server on the default port, using database 15.

When the server is started, it connects to the Redis server and uses the indexes in the key-value store.

Indexing regenerates the indexes in the Redis server – you do not have to restart the server for that.

#### SQLite{#indexes-types-sqlite}

TODO

#### File{#indexes-types-file}

TODO

### Accessing{#indexes-acessing}

If you don't have access to your indexes directly, like so

    books_index = Index.new(:books) do
      # ...
    end
    
    books_index.do_something_with_the_index

and for example you'd like to access the index from a rake task, you can use

    Picky::Indexes

to get *all indexes*.

To get a *single index* use

    Picky::Indexes[:index_name]

and to get a *single category*, use

    Picky::Indexes[:index_name][:category_name]

That's it.

### Configuration{#indexes-configuration}

This is all you can do to configure an index:

    books_index = Index.new :books do
      source   { Book.order("isbn ASC") }
    
      indexing removes_characters:                 /[^a-zA-Z0-9\s\:\"\&\.\|]/i,                    # Default: nil
               stopwords:                          /\b(and|the|or|on|of|in)\b/i,                   # Default: nil
               splits_text_on:                     /[\s\/\-\_\:\"\&\/]/,                           # Default: /\s/
               removes_characters_after_splitting: /[\.]/,                                         # Default: nil
               normalizes_words:                   [[/\$(\w+)/i, '\1 dollars']],                   # Default: nil
               rejects_token_if:                   lambda { |token| token == :blurf },             # Default: nil
               case_sensitive:                     true,                                           # Default: false
               substitutes_characters_with:        Picky::CharacterSubstituters::WestEuropean.new, # Default: nil
               stems_with:                         Lingua::Stemmer.new                             # Default: nil
    
      category :id
      category :title,
               partial:    Partial::Substring.new(:from => 1),
               similarity: Similarity::DoubleMetaphone.new(2),
               qualifiers: [:t, :title, :titre]
      category :author,
               partial: Partial::Substring.new(:from => -2)
      category :year,
               partial: Partial::None.new
               qualifiers: [:y, :year, :annee]
    
      result_identifier 'boooookies'
    end

Usually you don't need to configure all that.

But if your boss comes in the door and asks why X is not found… you know. And you can improve the search engine relatively *quickly and painless*.

More power to you.

### Data Sources{#indexes-sources}

Data sources define where the data for an index comes from.

You define them on an *index*:

    Index.new :books do
      source Book.all # Loads the data instantly.
    end
    
    Index.new :books do
      source { Book.all } # Loads on indexing. Preferred.
    end

Or even a *single category*:

    Index.new :books do
      category :title,
               source: lambda { Book.all }
    end

At the moment there are two possibilities: [Objects responding to #each](#indexes-sources-each) and [Picky classic style sources](#indexes-sources-classic).

#### Responding to #each{#indexes-sources-each}

Picky supports any data source as long as it supports `#each`.

See [under Flexible Sources](http://florianhanke.com/blog/2011/04/14/picky-two-point-two-point-oh.html) how you can use this.

In short. Model:

    class Monkey
      attr_reader :id, :name, :color
      def initialize id, name, color
        @id, @name, @color = id, name, color
      end
    end

The data:

    monkeys = [
      Monkey.new(1, 'pete', 'red'),
      Monkey.new(2, 'joey', 'green'),
      Monkey.new(3, 'hans', 'blue')
    ]

Setting the array as a source

    Index::Memory.new :monkeys do
      source   { monkeys }
      category :name
      category :couleur, :from => :color # The couleur category will take its data from the #color method.
    end

#### Delayed{#indexes-sources-delayed}

If you define the source directly in the index block, it will be evaluated instantly:

    Index::Memory.new :books do
      source Book.order('title ASC')
    end

This works with ActiveRecord and other similar ORMs since @Book.order@ returns a proxy object that will only be evaluated when the server is indexing.

For example, this would instantly get the records, since `#all` is a kicker method:

    Index::Memory.new :books do
      source Book.all # Not the best idea.
    end

In this case, you can give the `source` method a block:

    Index::Memory.new :books do
      source { Book.all }
    end

This block will be executed as soon as the indexing is running, but not earlier.

#### Classic Style{#indexes-sources-classic}

The classic style uses Picky's own `Picky::Sources` to load the data into the index.

    Index.new :books do
      source Sources::CSV.new(:title, :author, file: 'app/library.csv')
    end

Use this one if you want to use a simple CSV file.

However, you could also use the built-in Ruby `CSV` class and use it as an `#each` source (see above).

    Index.new :books do
      source Sources::DB.new('SELECT id, title, author, isbn13 as isbn FROM books', file: 'app/db.yml')
    end

Use this one if you want to use a database source with very custom SQL statements. If not, we suggest you use an ORM as an `#each` source (see above).

### Indexing / Tokenizing{#indexes-indexing}

See [Tokenizing](#tokenizing) for tokenizer options.

### Categories{#indexes-categories}

Categories – usually what other search engines call fields – define *categorized data*. For example, book data might have a `title`, an `author` and an `isbn`.

So you define that:

    Index.new :books do
      source { Book.order('author DESC') }
    
      category :title
      category :author
      category :isbn
    end

(The example assumes that a `Book` has readers for `title`, `author`, and `isbn`)

This already works and a search will return categorized results. For example, a search for "Alan Tur" might categorize both words as `author`, but it might also at the same time categorize both as `title`. Or one as `title` and the other as `author`.

That's a great starting point. So how can I customize the categories?

#### Option partial{#indexes-categories-partial}

The partial option defines if a word is also found when it is only *partially entered*. So, "Picky" might be already found when typing "Pic".

You define this by this:

    category :some, partial: Partial::Substring.new(from: -3)

(This is also the default)
The option `from: 1` will make a word completely partially findable.

If you don't want any partial finds to occur, use:

    category :some, partial: Partial::None.new

You can also pass in your own partial generators. See [this article](http://florianhanke.com/blog/2011/08/15/picky-30-its-all-ruby-part-1.html) to learn more.

#### Option weights{#indexes-categories-weights}

The weights option defines how strongly a word is weighed. By default, Picky rates a word according to the logarithm of its occurrence. This means that a word that occurs more often will be slightly higher weighed.

You define this by this:

    category :some, weights: MyWeights.new

The default is `Weights::Logarithmic.new`.

You can also pass in your own weights generators. See [this article](http://florianhanke.com/blog/2011/08/15/picky-30-its-all-ruby-part-1.html) to learn more.

If you don't want Picky to calculate weights for your indexed entries, you can use constant or dynamic weights.

With 0.0 as default weight:

    category :some, weights: Weights::Constant.new # Returns 0.0 for all results.

With 3.14 as set weight:

    category :some, weights: Weights::Constant.new(3.14) # Returns 3.14 for all results.

Or with a dynamically calculated weight:

    Weights::Dynamic.new do |str_or_sym|
      sym_or_str.length # Uses the length of the symbol as weight.
    end

You almost never need to use your specific weights. More often than not, you can fiddle with boosting combinations of categories, via the `boost` method in searches.

#### Option similarity{#indexes-categories-similarity}

The similarity option defines if a word is also found when it is typed wrong, or _close_ to another word. So, "Picky" might be already found when typing "Pocky~". (Picky will search for similar word when you use the tilde, ~)

You define this by this:

    category :some, similarity: Similarity::None.new

(This is also the default)

There are several built-in similarity options, like

    category :some, similarity: Similarity::Soundex.new
    category :this, similarity: Similarity::Metaphone.new
    category :that, similarity: Similarity::DoubleMetaphone.new

You can also pass in your own similarity generators. See [this article](http://florianhanke.com/blog/2011/08/15/picky-30-its-all-ruby-part-1.html) to learn more.

#### Option qualifier/qualifiers (categorizing){#indexes-categories-qualifiers}

Usually, when you search for `title:wizard` you will only find books with "wizard" in their title.

Maybe your client would like to be able to only enter "t:wizard". In that case you would use this option:

    category :some,
             :qualifier => :t

Or if you'd like more to match:

    category :some,
             qualifiers: [:t, :title, :titulo]

(This matches "t", "title", and also the italian "titulo")

Picky will warn you if on one index the qualifiers are ambiguous (Picky will assume that the last "t" for example is the one you want to use).

This means that:

    category :some,  :qualifier => :t
    category :other, :qualifier => :t

Picky will assume that if you enter "t:bla", you want to search in the :other category.

Searching in multiple categories can also be done. If you have:

    category :some,  :qualifier => :s
    category :other, :qualifier => :o

Then searching with "s,o:bla" will search for bla in both @:some@ and @:other@. Neat, eh?

#### Option from{#indexes-categories-from}

Usually, the categories will take their data from the reader or field that is the same as their name.

Sometimes though, the model has not the right names. Say, you have an italian book model, `Libro`. But you still want to use english category names.

    Index.new :books do
      source { Libro.order('autore DESC') }
    
      category :title,  :from => :titulo
      category :author, :from => :autore
      category :isbn
    end

#### Option key_format{#indexes-categories-keyformat}

You almost never use this, as the key format will usually be the same for all categories, which is when you would define it on the index, [like so](#indexes-keyformat).

But if you need to, use as with the index.

    Index.new :books do
      category :title,
               :key_format => :to_sym
    end

#### Option source{#indexes-categories-source}

You almost never use this, as the source will usually be the same for all categories, which is when you would define it on the index, "like so":#indexes-sources.

But if you need to, use as with the index.

    Index.new :books do
      category :title,
               source: some_source
    end

#### Searching{#indexes-categories-searching}

Users can use some special features when searching. They are:

* Partial: `something*` (By default, the last word is implicitly partial)
* Non-Partial: `"something"` (The quotes make the query on this word explicitly non-partial)
* Similarity: `something~` (The tilde makes this word eligible for similarity search)
* Categorized: `title:something` (Picky will only search in the category designated as title, in each index of the search)
* Multi-categorized: `title,author:something` (Picky will search in title _and_ author categories, in each index of the search)

These options can be combined (e.g. `title,author:"funky~"`): This will try to find similar words to funky (like "fonky"), but no partials of them (like "fonk"), in both title and author. 

Non-partial will win over partial, if you use both, as in `"test*"`.

Also note that these options need to make it through the [tokenizing](#tokenizing), so don't remove any of `*":,`.

### Key Format (Format of the indexed Ids){#indexes-keyformat}

By default, the indexed data points to keys that are integers, or differently said, are formatted using `to_i`.

If you are indexing keys that are strings, use `to_sym` – a good example are MongoDB BSON keys, or UUID keys.

The `key_format` method lets you define the format:

    Index.new :books do
      key_format :to_sym
    end

The `Picky::Sources` already set this correctly. However, if you use an `#each` source that supplies Picky with symbol ids, you should tell it what format the keys are in, eg. `key_format :to_sym`.

### Identifying in Results{#indexes-results}

By default, an index is identified by its *name* in the results. This index is identified by `:books`:

    Index.new :books do
      # ...
    end

This index is identified by `:media` in the results:

    Index.new :books do
      # ...
      result_identifier :media
    end

You still refer to it as `:books` in e.g. Rake tasks, `Picky::Indexes[:books].reload`. It's just for the results.

### Indexing{#indexes-indexing}

Indexing can be done programmatically, at any time. Even while the server is running.

Indexing *all indexes* is done with

    Picky::Indexes.index

Indexing a *single index* can be done either with

    Picky::Indexes[:index_name].index

or

    index_instance.index

Indexing a *single category* of an index can be done either with

    Picky::Indexes[:index_name][:category_name].index

or

    category_instance.index

### Loading{#indexes-reloading}

Loading (or reloading) your indexes in a running application is possible.

Loading *all indexes* is done with

    Picky::Indexes.load

Loading a *single index* can be done either with

    Picky::Indexes[:index_name].load

or

    index_instance.load

Loading a *single category* of an index can be done either with

    Picky::Indexes[:index_name][:category_name].load

or

    category_instance.load

#### Using signals{#indexes-reloading-signals}

To communicate with your server using signals:

    books_index = Index.new(:books) do
      # ...
    end
    
    Signal.trap("USR1") do
      books_index.reindex
    end

This reindexes the books_index when you call

    kill -USR1 <server_process_id>

You can refer to the index like so if want to define the trap somewhere else:

    Signal.trap("USR1") do
      Picky::Indexes[:books].reindex
    end

### Reindexing{#indexes-reindexing}

Reindexing your indexes is just indexing followed by reloading (see above).

Reindexing *all indexes* is done with

    Picky::Indexes.reindex

Reindexing a *single index* can be done either with

    Picky::Indexes[:index_name].reindex

or

    index_instance.reindex

Reindexing a *single category* of an index can be done either with

    Picky::Indexes[:index_name][:category_name].reindex

or

    category_instance.reindex