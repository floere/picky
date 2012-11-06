### Indexing{#indexes-indexing}

{.edit}
[edit](http://github.com/floere/picky/blob/master/web/source/documentation/_indexing.html.md)

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