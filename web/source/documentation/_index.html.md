## Single Page Help Index

{.edit}
[edit](http://github.com/floere/picky/blob/master/web/source/documentation/_index.html.md)

This is the one page help document for Picky.

Search for things using your browser (use ⌘F).

Edit typos directly in the [github page](http://github.com/floere/picky/tree/master/web/source/documentation) of a section using the [edit](http://github.com/floere/picky/blob/master/web/source/documentation/_index.html.md) button.

### Getting started{#index-getting-started}

It's [All Ruby](#all_ruby). You'll never feel powerless. [Look at your index data](#transparency) anytime.

#### Generating an app{#index-generating}

Creating an [example app](#generators) to get you up and running fast, [Servers](#generators-servers) or [Clients](#generators-clients).

Generating them:

* [Sinatra Server](#generators-servers-sinatra) and [Client](#generators-clients-sinatra)
* [Sinatra Server+Client in one](#generators-servers-allinone)

More infos on the [applications](#servers):

* [Sinatra](#servers-sinatra)([Routing](#servers-sinatra-routing), [Logging](#servers-sinatra-logging))
* [All In One (Client/Server)](#servers-allinone)

#### Integration in Rails/Sinatra etc.{#index-integration}

How to [integrate](#integration) Picky in:

* [Rails](#rails)
* [Sinatra](#sinatra)
* [DRb](#drb)
* [Ruby Script](#ruby_script)

### Tokenizing{#index-tokenizing}

How data is cut into little pieces for the index and when searching.

* [What is tokenizing?](#tokenizing)
* [Options](#tokenizing-options)
* [Using a custom tokenizer](#tokenizing-tokenizer)
* [Examples](#tokenizing-examples)
* [Advanced tokenizing](#tokenizing-notes)

### Indexes{#index-indexes}

How the data is stored and what you can do with [Indexes](#indexes).

Configuring an index:

* [Configuration](#indexes-configuration)

How does data get in there?

* [Indexing](#indexes-indexing)
* [Data Source Overview](#indexes-sources)
* [Source responding to #each](#indexes-sources-each)
* [_Classic Picky sources_](#indexes-sources-classic) _(deprecated from 5.0)_
* [When is the data for indexing loaded?](#indexes-sources-delayed)

How is the data categorized?

* [Categories](#indexes-categories)
* [Option partial](#indexes-categories-partial)
* [Option weight](#indexes-categories-weight)
* [Option similarity](#indexes-categories-similarity)
* [Option qualifier / qualifiers (categorizing)](#indexes-categories-qualifiers)
* [Option from](#indexes-categories-from)
* [Option key_format](#indexes-categories-keyformat)
* [Option source](#indexes-categories-source)
* [Option tokenize](#indexes-categories-tokenize)

How is the data prepared?

* [Indexing / Tokenizing](#indexes-indexing)

Getting at the data:

* [Accessing indexes and categories](#indexes-acessing)

There are four different [store types](#indexes-types):

* [Memory](#indexes-types-memory)
* [Redis](#indexes-types-redis)
* [SQLite](#indexes-types-sqlite)
* [File](#indexes-types-file)

Advanced topics:

* [Format of the indexed ids](#indexes-keyformat)
* [Reloading](#indexes-reloading)
* [Reindexing](#indexes-reindexing)
* [Using signals](#indexes-reloading-signals)
* [Which index did a result come from?](#indexes-results)

### Searching{#index-searching}

How to configure a search interface over an index (or multiple).

* [Search Interface Overview](#search)
* [Search Options](#search-options)
* [Searching / Tokenizing](#search-options-searching)

What options does a user have when searching?

* [User Search Options](#indexes-categories-searching)

Advanced topics:

* [Boosting](#search-options-boost) ([boosting a single category](#indexes-categories-weight))
* [Ignoring categories](#search-options-ignore)
* [Ignoring combinations of categories](#search-options-ignore-combination)
* [Keeping only specific combinations of categories](#search-options-only-combination)
* [Ignoring query words that are not found](#search-options-unassigned)
* [Maximum allocations (of tokens to categories)](#search-options-maxallocations)
* [Stopping a search early](#search-options-terminateearly)

#### Facets{#facets-index}

When you need a slice over a category's data.

* [Facets](#facets)
* [Index Facets](#index_facets)
* [Search Facets](#search_facets) (Using a query to filter your index facets)

#### Results{#index-results}

What a picky search returns.

* [Results Overview](#results)
* [Logging](#results-logging)
* [Sorting](#results-sorting)
* [Identification](#indexes-results)

### JavaScript{#index-javascript}

We include a [JavaScript library](#javascript) to make writing snazzy interfaces easier – see the [options](#javascript_options).

### Thanks{#index-thanks}

A bit of [thanks](#thanks)!