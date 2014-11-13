## Indexes{#indexes}


[edit](http://github.com/floere/picky/blob/master/web/source/documentation/_indexes.html.md)

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

When the server is started, they are loaded into memory. As soon as the server is stopped, the indexes are deleted from memory.

Indexing regenerates the JSON index files and can be reloaded into memory, even in the running server (see below).

#### Redis{#indexes-types-redis}

The Redis index saves its indexes in the Redis server on the default port, using database 15.

When the server is started, it connects to the Redis server and uses the indexes in the key-value store.

Indexing regenerates the indexes in the Redis server – you do not have to restart the server running Picky.

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

and to get a *single category* of an index, use

    Picky::Indexes[:index_name][:category_name]

That's it.

### Configuration{#indexes-configuration}

This is all you can do to configure an index:

    books_index = Index.new :books do
      source   { Book.order("isbn ASC") }
    
      indexing removes_characters:                 /[^a-z0-9\s\:\"\&\.\|]/i,                       # Default: nil
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

Usually you won't need to configure all that.

But if your boss comes in the door and asks why X is not found… you know. And you can improve the search engine relatively *quickly and painless*.

More power to you.

### Data Sources{#indexes-sources}

Data sources define where the data for an index comes from. There are [explicit data sources](#indexes-sources-explicit) and [implicit data sources](#indexes-sources-implicit).

#### Explicit Data Sources{#indexes-sources-explicit}

Explicit data sources are mentioned in the index definition using the `#source` method.

You define them on an *index*:

    Index.new :books do
      source Book.all # Loads the data instantly.
    end
    
    Index.new :books do
      source { Book.all } # Loads on indexing. Preferred.
    end

Or even on a *single category*:

    Index.new :books do
      category :title,
               source: lambda { Book.all }
    end
		
TODO more explanation how index sources and single category sources might work together.

Explicit data sources must [respond to #each](#indexes-sources-each), for example, an Array.

##### Responding to #each{#indexes-sources-each}

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

##### Delayed{#indexes-sources-delayed}

If you define the source directly in the index block, it will be evaluated instantly:

    Index::Memory.new :books do
      source Book.order('title ASC')
    end

This works with ActiveRecord and other similar ORMs since `Book.order` returns a proxy object that will only be evaluated when the server is indexing.

For example, this would instantly get the records, since `#all` is a kicker method:

    Index::Memory.new :books do
      source Book.all # Not the best idea.
    end

In this case, it is better to give the `source` method a block:

    Index::Memory.new :books do
      source { Book.all }
    end

This block will be executed as soon as the indexing is running, but not earlier.

#### Implicit Data Sources{#indexes-sources-implicit}

Implicit data sources are not mentioned in the index definition, but rather, the data is added (or removed) via *realtime* methods on an index, like `#add`, `#<<`, `#unshift`, `#remove`, `#replace`, and a special form, `#replace_from`.

So, you *don't* define them on an index or category as in the explicit data source, but instead add to either like so:

    index = Index.new :books do
      category :example
    end
    
    Book = Struct.new :id, :example
    index.add Book.new(1, "Hello!")
    index.add Book.new(2, "World!")

Or to a specific category:

    index[:example].add Book.new(3, "Only add to a single category")

##### Methods to change index or category data{#indexes-sources-implicit-methods}

Currently, there are 7 methods to change an index:

* `#add`: Adds the thing to the end of the index (even if already there). `index.add thing`
* `#<<`: Adds the thing to the end of the index (shows up last in results). `index << thing`
* `#unshift`: Adds the thing to the beginning of the index (shows up first in results). `index.unshift thing`
* `#remove`: Removes the thing from the index (if there). `index.remove thing`
* `#replace`: Replaces the thing in the index (if there, otherwise like `#add`). Equal to `#remove` followed by `#add`. `index.replace thing`
* `#replace_from`: Pass in a Hash. Replaces the thing in the index (if there, otherwise like `#add`). Equal to `#remove` followed by `#add`. `index.replace id: 1, example: "Hello, I am Hash!"`

### Indexing / Tokenizing{#indexes-indexing}

See [Tokenizing](#tokenizing) for tokenizer options.