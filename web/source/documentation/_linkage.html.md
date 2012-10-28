## Single Page Help Index

This is the one page help document for Picky.

Search for things using your browser (eg. ⌘F).

Edit typos directly in the [github page](#todo) using the edit button.

### Getting started

It's [All Ruby](#all_ruby). [Transparency](#transparency) matters.

#### Generating an app

Creating an example app to get you up and running fast.

[Generators](#generators)
    * [Servers](#generators-servers)
        * [Sinatra](#generators-servers-sinatra)
        * [All In One](#generators-servers-allinone)
    * [Clients](#generators-clients)
        * [Sinatra](#generators-clients-sinatra)
* [Servers / Applications](#servers)
    * [Sinatra Style](#servers-sinatra)
        * [Routing](#servers-sinatra-routing)
        * [Logging](#servers-sinatra-logging)
    * [All In One (Client + Server)](#servers-allinone)

#### Integration in Rails/Sinatra etc.

Picky in various environments.

[Rails](#rails)
[Sinatra](#sinatra)
[DRb](#drb)
[Ruby Script](#rubyscript)

### Tokenizing{#index-tokenizing}

How data is cut into little pieces for the index and when searching.

[Tokenizing](#tokenizing)
[Options](#tokenizing-options)
[Tokenizer](#tokenizing-tokenizer)
[Examples](#tokenizing-examples)
[Notes](tokenizing-notes)

### Indexes

[Indexes](#indexes)

There are four different [types](#indexes-types):
[Memory](#indexes-types-memory),
[Redis](#indexes-types-redis),
[SQLite](#indexes-types-sqlite), and
[File](#indexes-types-file)

[Accessing](#indexes-acessing)
    * [Configuration](#indexes-configuration)
    * [Data Sources](#indexes-sources)
        * [Responding to #each](#indexes-sources-each)
        * [Delayed](#indexes-sources-delayed)
        * [Classic Style](#indexes-sources-classic)
    * [Indexing / Tokenizing](#indexes-indexing)
    * [Categories](#indexes-categories)
        * [Option partial](#indexes-categories-partial)
        * [Option weights](#indexes-categories-weights)
        * [Option similarity](#indexes-categories-similarity)
        * [Option qualifier / qualifiers (categorizing)](#indexes-categories-qualifiers)
        * [Option from](#indexes-categories-from)
        * [Option key_format](#indexes-categories-keyformat)
        * [Option source](#indexes-categories-source)
        * [Searching](#indexes-categories-searching)
    * [Key Format (Format of the indexed Ids)](#indexes-keyformat)
    * [Identifying in Results](#indexes-results)
    * [Indexing](#indexes-indexing)
    * [Reloading](#indexes-reloading)
        * [Using signals](#indexes-reloading-signals)
    * [Reindex](#indexes-reindexing)

### Searching

How to search over indexes.

* [Search](#search)
    * [Options](#search-options)
        * [Searching / Tokenizing](#search-options-searching)
        * [Boost](#search-options-boost)
        * [Ignore Categories](#search-options-ignore)
        * [Ignore Unassigned Tokens](#search-options-unassigned)
        * [Maximum Allocations](#search-options-maxallocations)
        * [Early Termination](#search-options-terminateearly)

#### Results

What a picky search returns.

[Results](#results)
    * [Logging](#results-logging)
    * [Sorting](#results-sorting)