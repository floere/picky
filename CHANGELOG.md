## 4.20.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- Added `Index#static` option, which will cause the realtime index not to be used when using a source on an index. We recommend to use this when you do not often change index data, but load the index once then run the engine for searches.

## 4.19.7

###### [Client](https://github.com/floere/picky/tree/master/client)

- Fix rspec matcher loading.

## 4.19.6

- Loosen gem restrictions on activesupport.

## 4.19.5

###### [Client](https://github.com/floere/picky/tree/master/client)

- Only add have_categories matcher to client/spec helpers if RSpec::Matcher exists.
- Various small bugfixes and refactorings.

## 4.19.4

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fixes made to the `Picky::Splitters::Automatic` algorithm.

## 4.19.3

###### [Client](https://github.com/floere/picky/tree/master/client)

- Updated Picky Javascript: The success callback gets (data, query) instead of (data). The query is the query of the request that resulted in the success callback.
- Fix order of categories in example.

## 4.19.2

###### [Server](https://github.com/floere/picky/tree/master/server)

- Avoid Rails 4 logger deprecation warning (thanks @albandiguer).

## 4.19.1

###### [Server](https://github.com/floere/picky/tree/master/server)

- Explicitly require 'strscan'.

## 4.19.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- Picky uses `StringScanner` instead of `String#split` to reduce `String` usage. If only a single word is used in a query instead of a former 3, no new ones are created, reducing amount of GC runs (and enhancing performance). If two words are used, two new ones are created instead of 5, and so on. Thanks to @kasparschiess and @zmoazeni.
- Picky core has been slightly optimised.

## 4.18.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- Many code paths minimized: speedup of roughly 20% over last version (in standard cases).
- Default lambda for Tokenizer#rejects\_token\_if is &:empty? instead of &:blank?.
- Changes in how SQLite client is initialized. Method SQLite::Basic#lazily\_initialize\_client replaced by SQLite::Basic#db.
- Token#partial? is calculated at create time, not dynamically.
- Internal API changes in Allocation (indirection removed).
- More informative error messages.

## 4.17.1

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fix for parallel tokenizing when option `tokenize` is set to false on a category.

## 4.17.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- Added OR mode to Picky search terms, e.g. `hello world|florian`. This will find results for "hello world" and "hello florian". This works with similarity, partial, etc. For example `hello text:wor*|text:flarian~`. (Note that you will have to NOT `remove_characters` "|")

## 4.16.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- `key_format` is now explicitly needed unless the keys do not need to be converted.
- Search facets do not report duplicate entries under 1000 facets.

## 4.15.1

###### [Server](https://github.com/floere/picky/tree/master/server)

- The `from` category option accepts anything that can be called. For example, `category :authors, :from => lambda { |book| book.authors.map(&:name).join(" ") }`.
- Key format `:split` can be used, in case of a string id. This results in an array be stored as IDs.
- Arrays can be used as IDs if you use the in-memory backend.

## 4.15.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- Completely rewritten and more standard C code compilation/inclusion.

## 4.14.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- Add `tokenize` option on category. Set to `false` when you already pre-tokenize the category (default is `true`).

## 4.13.1

###### [Server](https://github.com/floere/picky/tree/master/server)

- The `#only` and `#ignore` options on `Search` now work as expected (`Array`s describe order of categories in allocations – so `[:title, :author]` will also match `[:title, :title, :author, :author, :author]`).
- Removed `#to_json` from `Hash` and `Allocation`.

## 4.13.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- Warn on erroneous category options, eg. :weights instead of :weight (thanks @rogerbraun).

## 4.12.13

###### [Server](https://github.com/floere/picky/tree/master/server)

- Make use of Redis' SCRIPT LOAD feature.

## 4.12.12

###### [Server](https://github.com/floere/picky/tree/master/server)

- Handle script flush in Redis backend (if SCRIPT FLUSH is called, EVALSHA will raise an error).

## 4.12.11

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fix: Redis searching, script reuse.

## 4.12.10

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fix: Redis searching, realtime mode (thanks for pushing @andi and @rogerbraun).

###### [Generators](https://github.com/floere/picky/tree/master/generators)

- Removed i18n from client Gemfile.

## 4.12.9

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fix: Directory creation (thanks @rogerbraun).

## 4.12.8

###### [Client](https://github.com/floere/picky/tree/master/client)

- Fix: use PUT instead of POST for replace action (thanks @rogerbraun).

## 4.12.7

###### [Client](https://github.com/floere/picky/tree/master/client)

- Added `Picky::Client#to_s` method.
- Cleaned JS source code, fixed header allocation information.

## 4.12.6

###### [Generators](https://github.com/floere/picky/tree/master/generators)

- Reimplemented `Search#ignore` for single categories (see 4.12.5 and use a single category name symbol).
- Removed generator file duplication.

## 4.12.5

###### [Server](https://github.com/floere/picky/tree/master/server)

- Added experimental options `Search#only` and `Search#ignore`.
  
  Example:
    people = Search.new(people_index) do
      only [:first_name, :last_name],
           [:last_name, :first_name]
    end

## 4.12.4

###### [Generators](https://github.com/floere/picky/tree/master/generators)

- Removed `rake index` from generated client (thanks @kschiess!).

## 4.12.3

###### [Server](https://github.com/floere/picky/tree/master/server)

- Added `CharacterSubstituters::Polish` (thanks @prami!) – substitutes various Polish characters with their ascii counterparts.

## 4.12.2

###### [Generators](https://github.com/floere/picky/tree/master/generators)

- Extracted index/search into separate files, like most people seem to like it.

## 4.12.1

###### [Client](https://github.com/floere/picky/tree/master/client)

- Reverted last change, and uses `.find_all_by_id` instead of `.find_by_id` (thanks to @prami).

## 4.12.0

###### [Client](https://github.com/floere/picky/tree/master/client)

- `Picky::Convenience#populate_with` offers a new option `finder_method` where you can the object finding method. It will be given an array of ids and options given to `#populate_with` (minus `up_to` and `finder_method`), thanks @joho!
- Breaking: By default, `#populate_with` uses `.find_by_id` instead of `.find` on the given (model class) instance. This will simply continue to work if you use `ActiveRecord`.

###### [Server](https://github.com/floere/picky/tree/master/server)

- Experimental feature: Automatic input splitting. Use when you can't use eg. space. Initialize as `Picky::Splitters::Automatic.new(index_category)`. Offers the method `#split(text) # => ['split', 'text']`. This means you can use this for the option `splits_text_on` instead of a `Regexp`.

## 4.11.4

###### [Generators](https://github.com/floere/picky/tree/master/generators)

- Removed unnecessary jQuery History.js adapter file.

## 4.11.3 "A range of customizations"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Experimental feature: Ranges can now be customized. Pass a category an option `ranging: CustomRanger`. That class has to initialize like `Range.new(min, max)`, but can offer a specialized `#inject` method which can yield a custom order. (Alternatively, implement `#each` and `include Enumerable`)
- Thanks to @andykitchen for this one.

## 4.11.2 "A range of features"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Experimental feature: Range query over natural ranges, ie. numeric or alphabetical.
- Examples: `2000-2008`, `year:2000-2008` (adding a qualifier is recommended, faster and usually known). Though: Use `year:200*` if you want fixed ranges `2000-2009`, `2010-2019`, etc.
- Be clever in your use of ranges. If they are not flexibly chooseable by the user, don't use them. Be also wary in this initial version of huge range: `0-1000000` is a bad idea. If your range encompasses all values, simply don't use a range query.

## 4.11.1 "Whoops"

###### [Generators](https://github.com/floere/picky/tree/master/generators)

- Fix: Include a server Gemfile with the generator (thanks @mbajur for noticing!).

## 4.11.0 "Separate Qualifiers"

###### [Server](https://github.com/floere/picky/tree/master/server)

- If you have a search with multiple indexes, it will now map the same qualifier to different categories in multiple indexes. Example, if you search for "name:bla", then the name qualifier will be mapped to the respective category on each index. We do not recommend to use the same category names on different indexes if they are used in the same search.
- Removed: Method `Picky::Search#only`. We will reinstate it in version 5+.

## 4.10.0 "Lumberjack know logging"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Picky Loggers now also accept Ruby Logger instances instead of just IO instances: `Picky.logger = Picky::Loggers::Concise.new Logger.new('log/some.log')`. `Picky.logger = Picky::Loggers::Concise.new`
- Same three logging types still available: `Picky::Loggers::Silent`, `Picky::Loggers::Concise`, `Picky::Loggers::Verbose`.
- Picky now outputs all warnings/info to the logger set in `Picky.logger=` (available via `Picky.logger`).

## 4.9.0 "Stop slacking"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Procrastinate gem is optional (add when you wish parallel indexing).

## 4.8.1 "source equals data"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Added `Picky::Category#source=`. Each category can have a different source, mostly used for different sorting.

## 4.8.0 "The only constant is change"

###### [Client](https://github.com/floere/picky/tree/master/client)

- Removed `PICKY_ROOT` and did not replace it.

###### [Server](https://github.com/floere/picky/tree/master/server)

- Removed `PICKY_ROOT` and replaced it with `Picky.root = "absolute path"` and `Picky.root # => Current Picky root directory (used for indexes).`

## 4.7.0 "Yajl house rock"

###### [Server](https://github.com/floere/picky/tree/master/server)

- By default, we use Yajl if it is available, via `MultiJson.use :yajl if defined? ::Yajl`.
- Use `MultiJson.use :your_prefered_adapter` explicitly to change the adapter.

## 4.6.6 "All development stems from open source"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Experimental update: Stemming.
- New tokenizer (indexing/searching) option: `stems_with`. Give it a thing that responds to `#stem(text) # => stemmed_text`.
- See [https://github.com/floere/picky/blob/master/server/spec/functional/stemming_spec.rb](https://github.com/floere/picky/blob/master/server/spec/functional/stemming_spec.rb) for examples.

## 4.6.5 "Help is on the way"

###### [Server](https://github.com/floere/picky/tree/master/server)

- More helpful tokenizer error message.

## 4.6.4 "Swish swish clang clang"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fixes issues with Clang on OSX (thanks Andy Kitchen!).

## 4.6.3 "Qualifier remapping"

###### [Server](https://github.com/floere/picky/tree/master/server)

- If you add categories dynamically _after_ using the index in a search, you have to call `search.remap_categories` to have the new category's qualifiers registered. 

## 4.6.3 "spermy operation"

- The spermy operator (~>) in the gemspec is not consistent over all version granularities.

## 4.6.2 "actively support activesupport"

- Also allow activesupport 4 (Note: Untested, assuming semantics didn't change and version change is Rails related).

## 4.6.1 "small change"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Many small internal improvements.

## 4.6.0 "better being prepared than prepared prepared"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Important Note: This release changes the file location of the prepared indexes! If you rely on this not changing, you need to adapt your scripts!
- Prepared files had a double "prepared" and an unnecessary "index" in the file name. They do not anymore. For example, `prepared_keywords_index.prepared.txt` has changed to `keywords.prepared.txt`, the tokenized index for the keywords category.

## 4.5.12 "counts count more than weights"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Facets API now returns counts rather than weights.
- Facets API changed option `more_than` into `at_least` – give if you need facets with at least a certain count.
- Facets API added option `counts` (`true`/`false`) – `facets` methods will return a hash with counts if `true` or not given, ie. `nil`, and an array if `false`.

## 4.5.11 "partial to facets"

###### [Server](https://github.com/floere/picky/tree/master/server)

- `Search#facets` now does access the partial index, but always the exact index.

## 4.5.10 "fastcets"

###### [Server](https://github.com/floere/picky/tree/master/server)

- `Search#facets` performance improved.

## 4.5.8 / 4.5.9 "ruby and its many facets"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Experimental simple facets support.
- Added `Index#facets(:category_name, options = {})` with `options`: `more_than` (a minimum weight a facet needs to have to be included). Will return keys and weights.
- Added `Search#facets(:category_name, options = {})` with `options`: `filter` (a query to filter with, e.g. `'brand:mammut'`), and `more_than` (a minimum weight, see above).
- Note – if your data is very dirty (ie. many facets that occur only once./), consider using a minimum to speed up the facets query!
- Usage – `products.facets :brand_name, filter: 'category:boots', more_than: 0` (will return all `brand_name` facets filtered by `'category:boots'` that have more weight than `0`).

## 4.5.7 "bel hevy"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Added category option `weight`. The `weight` option now takes a number and adds that to the default logarithmic weighing. E.g. `weight: +6` (very strong positive weight) or `weight: -0.5` (slightly negative weight). This results in a higher/lower score.

## 4.5.5 / 4.5.6 "swish swish clang clang"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Clang can now compile Picky.
- Much better error message in case Picky can't be compiled.
- Clean compilation on gem install.

## 4.5.4 "like stripes on a car"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Removed code, making Picky approximately 10% faster.

## 4.5.3 "hero koo koo"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Check for the existence of `RbConfig` before compiling.

## 4.5.2 "statistically probable"

###### [Statistics](https://github.com/floere/picky/tree/master/statistics)

- New experimental statistics interface. Run `picky stats` to get the usage.

## 4.5.1 "JSON, a nightmare"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fix for `multi_json` gem usage.

## 4.5.0 "JSON, a nightmare on Elm street"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Picky now uses the `multi_json` gem.

## 4.4.2 "not carbon copy"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Implements [a suggestion by David Lowenfels](https://groups.google.com/forum/?fromgroups#!topic/picky-ruby/8kuG8FkATgU) which enables a Picky user to set the CC environment variable to define which C compiler is used.

## 4.4.1 "even more unique"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fix for bug introduced in 4.4.0, `unique` option works correctly with offset.

## 4.4.0 "unique like a snowflake"

###### [Server](https://github.com/floere/picky/tree/master/server)

Unique option on search instance. This will remove each result id in allocations if they have appeared in preceding allocations. What does this mean?

Example:
You search for `"picky search"`. And you find it in two allocations, `name, type` and `name, name`. Let's say Picky finds ids `[1, 2, 3]` in `name, type` and then `[2, 3, 4]` in `name, name`. Picky will then remove `2 and 3` from `name, name` because they have been found in `name, type` already.

Usually this is used when you only want a list of unique ids in the results.

- Added `unique: truey/falsy` option on `Search#search`. Use like this: `search_instance.search 'query', 20, 0, unique: true`.

## 4.3.2 "show of character"

###### [Server](https://github.com/floere/picky/tree/master/server)

This version lets you define control characters on tokens, like so (shows how, and the default):

- `Picky::Query::Token.partial_character = '\*'` for searching partially.
- `Picky::Query::Token.no_partial_character = '"'` for _not_ searching partially.
- `Picky::Query::Token.similar_character = '~'` for searching similar strings.
- `Picky::Query::Token.no_similar_character = '"'` for _not_ searching similar strings.
- `Picky::Query::Token.qualifier_text_delimiter = ':'` for telling qualifier and string apart (`title:sometitle`).
- `Picky::Query::Token.qualifiers_delimiter = ','` for telling qualifiers apart (`title,author:bla`).

The first four are going to be interpolated into `%r`, so escape the character like you would in a regexp. The last two are used in `String#split`, so doing this is not necessary.

So, for example, if you set

`Picky::Query::Token.partial_character = '…'`

`Picky::Query::Token.qualifier_text_delimiter = '?'`

`Picky::Query::Token.qualifiers_delimiter = '|'`

Then you can search like so:

`something.search("title|author?wittgenstei…")`

## 4.3.1 "status anxiety"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Sinatra index actions now return more sensible HTTP status codes.

## 4.3.0 "evening wear"

###### [Client](https://github.com/floere/picky/tree/master/client)

- Gorgeous new design (thanks `tvandervossen!)
- Completely overhauled Picky JavaScript.

## 4.2.4 "fileutils"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Require fileutils regardless of the Ruby version Picky is run in. 

## 4.2.3 "overbird"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Require fileutils in case we run Picky on MacRuby (thanks overbryd).

## 4.2.2 "cheese royale"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Use the "standard" way to detect the Ruby engine used for MacRuby.

## 4.2.1 "fries with that"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Experimental extensions to get Picky run on MacRuby 0.12.
- Unfortunately, we dom't have the resources to always run the tests – please use with caution.

## 4.2.0 "talk to the hand"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Redesigned how Picky logs: Picky itself logs its index handling (tokenizing/dumping/loading) using one of its built-in loggers. Set a logger after requiring 'picky' like this: `Picky.logger = Picky::Loggers::Verbose.new(STDOUT) # or any IO`. Default is `Picky::Loggers::Concise.new(STDOUT)` aka `Picky::Loggers::Default`. Also an option is `Picky::Loggers::Silent`. This closes [issue 70](https://github.com/floere/picky/issues/70).
- Note: Logging searches is your job (see generated examples on how to do this).

## 4.1.0 "identification needed"

###### [Server](https://github.com/floere/picky/tree/master/server)

- `Picky::Results#ids(only = nil)` returns the amount of ids originally requested, except if an `only` amount gets passed in (then that amount is used).

## 4.0.9 "new york new york"

###### [Client](https://github.com/floere/picky/tree/master/client)

- `Picky::Client::ActiveRecord.configure(options)` added as an alias of `new` (thanks auastro!).

###### [Server](https://github.com/floere/picky/tree/master/server)

- `require 'picky/sinatra/index_actions'` is not necessary anymore to load the index actions. They are required automatically with `require 'picky/sinatra'`.

## 4.0.8 "smoke and mirrors"

###### [Client](https://github.com/floere/picky/tree/master/client)/[Server](https://github.com/floere/picky/tree/master/server)

- Encode data part in JSON.

## 4.0.7 "supermodel"

- Experimental ActiveRecord 3.0+ integration release. See below.

###### [Client](https://github.com/floere/picky/tree/master/client)

- ActiveRecord models can now use `extend Picky::Client::ActiveRecord.new(*attributes_to_send, options = {})` to have the model send updates/deletes back to the Picky server. Note that error handling is not yet built in. The server needs to be up and running.

###### [Server](https://github.com/floere/picky/tree/master/server)

- The Sinatra style server can now `extend Picky::Sinatra::IndexActions` to install index updating POST/DELETE methods on the "/" path (Note: Currently needs a `require 'picky/sinatra/index_actions'` beforehand). 

## 4.0.6 "bug #57"

###### [Client](https://github.com/floere/picky/tree/master/client)

- Fixed [bug #57](https://github.com/floere/picky/issues/57), multicategory selections in the Javascript user interface.

## 4.0.5 "only :you"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Experimental release of `only` option for searches. Does the same as `only:that_category`, but implicitly, in the search. E.g. `only :cat1, :cat2`.

## 4.0.4 "opinionated environment"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Default amount of similar tokens is now set to 3 instead of 10 for phonetic similarities.
- Server uses PICKY_ENV environment variable before RUBY_ENV and then RACK_ENV.

## 4.0.2/3 "mea culpa"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fix for realtime indexing when using specific options.

## 4.0.1 "unauthorized"

###### [Server](https://github.com/floere/picky/tree/master/server)

- Customized `weight` and `similarity` do not need the `saved?` method anymore.

## 4.0.0 "singing in the rain"

- No changes from 4.0.0pre7.

## 4.0.0pre7

###### [Server](https://github.com/floere/picky/tree/master/server)

- BREAKING The `tokenizer` option for a category has been renamed to `indexing`, to conform with the methods for the index and the sinatra app.
- BREAKING Internal `Similarity#encoded` method has been renamed to `#encode`.

## 4.0.0pre6

###### [Server](https://github.com/floere/picky/tree/master/server)

- Similarity API fixed.

## 4.0.0pre5

###### [Statistics](https://github.com/floere/picky/tree/master/statistics)

- Only use 0.01s for checking the log file instead of 0.1.

## 4.0.0pre4

###### [Statistics](https://github.com/floere/picky/tree/master/statistics)

- Overhauled statistics interface. Use `picky statistics log/search.log` to start it.

## 4.0.0pre3

###### [Server](https://github.com/floere/picky/tree/master/server)

- BREAKING Reverting customizeable backends from version 3.3.2. They are no longer available. Please use simple subclassing to achieve funky backends.
- BREAKING SQLite `self_indexed` and Redis `immediate` option is now called `realtime`, as changes go directly through to the actual backends, in "realtime".
- The `Index#source` block is now evaluated every time an indexer runs.

## 4.0.0pre2

###### [Server](https://github.com/floere/picky/tree/master/server)

- BREAKING Removed Picky classic application. Please use Picky e.g. in a Sinatra app.
- BREAKING Removed Picky classic sources. Please use a source with the #each method.
- BREAKING Option `weights` for the `Picky::Index#category` method has been renamed `weight` to conform with the other methods.
- BREAKING Picky does not require the text gem anymore by default. Only when you use phonetic similarity. It will tell you what it needs.
- BREAKING Added the PICKY_ENVIRONMENT in front of the Redis key namespace to differentiate the various environments.
- BREAKING Removed `rake routes` since only the classic server was able to provide it.
- BREAKING Removed the classic server from the generators.
- Explicitly uses `Yajl::Encoder#encode` for JSON encoding.
- Fixed cases where even when no similarity was defined on a category, similar results were still found.
- Rake task `index` now points to task `index:parallel` by default. Call `rake:serial` to index serially.
- Indexer calls `reconnect!` on sources that support it.
- Location/Volumetric/Geosearch rewritten.

## 4.0.0pre1

###### [Server](https://github.com/floere/picky/tree/master/server)

- BREAKING `Picky::Indexes.index` does not index in parallel anymore.
- BREAKING Renamed `Picky::Indexes.index_for_tests` to `Picky::Indexes.index`.
- If you want to explicitly run parallel indexing programmatically, use `Picky::Indexes.index Picky::Scheduler.new(parallel: true)` or `Picky::Indexes[:index_name].index Picky::Scheduler.new(parallel: true)`.
- BREAKING Renamed `Picky::Wrappers::Category::ExactFirst` to `Picky::Results::ExactFirst`. Extend instead of wrap: `index.extend Results::ExactFirst` or `category.extend Results::ExactFirst`. If an index is extended, each category of the index will be extended.
- BREAKING `Picky::Indexes.reload` has been renamed to `Picky::Indexes.load`.
- BREAKING `index.reload` has been renamed to `index.load`.
- BREAKING `category.reload` has been renamed to `category.load`.
- BREAKING Removed all `define_...` methods on indexes.
- Using the `procrastinate` gem to parallelize indexing.
- Indexing call structure cleaned up. Improves performance by about 40%.

###### [Generators](https://github.com/floere/picky/tree/master/generators)

- Fixed integration specs for the generated "all in one" server/client.
- Changed method calls to adapt to above changes.

## 3.6.16

###### [Server](https://github.com/floere/picky/tree/master/server)

- Semantics for terminate_early(n) are to calculate n more allocations than necessary. A n of 0 means that only exactly the number of necessary allocations for the ids is calculated.

## 3.6.14/15

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fix for terminate_early with offsets in 3.6.12 (thanks niko!).

## 3.6.13

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fix for exact first matching (thanks geelen!).

## 3.6.12

###### [Server](https://github.com/floere/picky/tree/master/server)

- `Picky::Search` option `terminate_early(integer)` or `terminate_early(with_extra_allocations: integer)` introduces early termination. If in your interface you only need the ids and no total, then this is the option for you. Calling `terminate_early` without parameters will use 0 as the default.
- Fix for exact first matching (thanks geelen!).

## 3.6.11

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fix for bad performance bug introduced somewhere in 2.4.
- Backends rewritten to support realtime indexes (SQLite, Redis). Memory already supported it (needs call to `Index#build_realtime_mapping` after loading if dumped+loaded). File backend will not support realtime index in the near future.
- Experimental, use at your own peril: Method to build the realtime index, explicitly: `Index#build_realtime_mapping`.

## 3.6.10

###### [Server](https://github.com/floere/picky/tree/master/server)/[Generators](https://github.com/floere/picky/tree/master/generators)

- script/console command minified in the generation and moved to the server.

## 3.6.9

###### [Generators](https://github.com/floere/picky/tree/master/generators)

- The generated client will now use the raw JS file from Github (http://github.com/floere/picky/issues/46).

## 3.6.8

###### [Server](https://github.com/floere/picky/tree/master/server)

- BREAKING Renamed the undocumented `Tokenizer#maximum_tokens(integer)` to `Tokenizer#max_words(integer)`. Restricts the amount of words that the tokenizer lets through to the core search engine.
- Added `Search#max_allocations(integer)` to restrict number of allocations that are actually calculated (to avoid combinatorial and UI explosions).
- Added `<<` and `unshift` on `Index` and `Category`. The `unshift` method behaves like the `add` method when that one is called without a second parameter. Use like `index << Thing.new(1, 'some text', 'some other text')`.
- Existence of a source is only checked when really needed. Will fail hard if there is none, with a (hopefully) useful error message.

## 3.6.7

###### [Server](https://github.com/floere/picky/tree/master/server)

- Experimental #build_realtime_mapping method to rebuild the realtime mapping helper after a dump/load.

## 3.6.6

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fix and regression spec for a Redis backend bug introduced in 3.6.5.

## 3.6.5

###### [Server](https://github.com/floere/picky/tree/master/server)

- Exact-first wrapper for experimental purposes.

## 3.6.4

###### [Server](https://github.com/floere/picky/tree/master/server)

- Removed active record, redis, mysql dependencies from picky.gemspec.

## 3.6.3

###### [Server](https://github.com/floere/picky/tree/master/server)

- From Redis 2.6.0 on, Picky will be around 65% faster with Redis as a backend.

## 3.6.2

###### [Client](https://github.com/floere/picky/tree/master/client)

- Fixed Javascript. See [https://github.com/floere/picky/issues/47](https://github.com/floere/picky/issues/47).

###### [Server](https://github.com/floere/picky/tree/master/server)

- Weights now only saved up to the third position after the decimal point.
- SQLite backend has been renamed from `Sqlite` to `SQLite`.
- Backends can be switched dynamically (use `index.backend = new_backend`). Used for performance tests.

## 3.6.1

###### [Server](https://github.com/floere/picky/tree/master/server)

- Removed sqlite3 from gemspec to enable Heroku compatibility. Please add it in your Gemfile if you need it or simply install the gem separately.

## 3.6.0

This release includes BREAKING changes. See below.

###### [Server](https://github.com/floere/picky/tree/master/server)

- This version tries to reduce maintenance complexity and prepare for 4.0.
- BREAKING In your code, rename any occurrences of `Indexes.reload`, `Indexes#reload`, `Index#reload`, `Category#reload` with an equivalent `load` method.
- Renamed `load_from_cache` with `load` on `Indexes`, `Index`, `Category`.
- Removed `rake check` and related methods with no replacement. Please tell us if you miss it.
- Removed `Index#backup`, `Index#restore` and related methods on `Category` etc. with no replacements. Please tell us if you miss them.
- Fix for the problem that `#remove(id)` didn't remove when a different key_format than the standard one was defined (Thanks niko!).

## 3.5.4

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fix for using `Rack::Harakiri` in an example project. (Ok, time for bed)

## 3.5.3

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fix for using dynamic weights and then deleting something from it.

## 3.5.2

###### [Server](https://github.com/floere/picky/tree/master/server)

- Changed the way the internal backend is dumped to json or marshalled.

## 3.5.1

###### [Server](https://github.com/floere/picky/tree/master/server)

- `generate_from` methods have been removed from all generators as they are not used anymore.
- Added the option of having dynamic weights calculation. Use this if you don't need weights based on the amount of indexed ids per token. This does not generate an index in the backend (Redis or file), but calculates the weight at runtime. Examples: Always return the default 0.0, `category :text, weights: Picky::Weights::Constant.new` or always return 3.14, `category :text1, weights: Picky::Weights::Constant.new(3.14)` or calculate a weight at runtime, based on the size of the str_or_sym we are looking for, `category :text1, weights: Picky::Weights::Dynamic.new { |str_or_sym| str_or_sym.size }`. We recommend using search boosts to boost specific category combinations.

## 3.5.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- Internally, tokens are held as strings. This helps dealing with memory issues when using realtime indexes. This might make Picky's memory usage a bit higher that before. However, when using realtime indexes, the memory usage will be much improved.
- Complete internal rewrite of how indexing is handled.

## 3.4.3

###### [Server](https://github.com/floere/picky/tree/master/server)

- Performance fix for problem introduced in 3.4.3.

## 3.4.2

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fixed a bug where ids occurred multiple times for an indexed token in the same index bundle (thanks M. Below for finding the bug). This did not impact on the search results, just the stored index files.

## 3.4.1

###### [Server](https://github.com/floere/picky/tree/master/server)

- Intermittent service release to test internal String-based indexes.

## 3.4.0

###### [Client](https://github.com/floere/picky/tree/master/client)

- Method `populate_with` keeps the ids by default. Use `clear_ids` on the results if you want to remove them.

## 3.3.3

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fixing [issue 38](https://github.com/floere/picky/issues/38). Possibly caused by [a problem described here](http://blog.rubygems.org/2011/08/31/shaving-the-yaml-yak.html).

## 3.3.2

###### [Server](https://github.com/floere/picky/tree/master/server)

- Internal interface for generators changed. The generators are now used directly, e.g.: `Picky::Generators::Partial::Substring.new(from: 1).generate_from inverted_index_hash`. No change on your part is necessary if you didn't use `Picky::Generators::{Partial,Weights,Similarity}Generator`.
- Experimental exchangeable backend change: `Redis now passes bundle, client into the lambda, instead of client, bundle`. E.g. `inverted: ->(bundle, client) { Picky::Backends::Redis::List.new(client, "#{bundle.identifier}:inverted") }`

## 3.3.1

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fix for `Partial::None`, introduced in 3.3.0.

## 3.3.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- ActiveRecord is not loaded anymore by default, as only few users use the Picky db source (if you do, Picky will try to require it and tell you if it can't).
- It is now possible to explicitly dump an index, using `index.dump`. This is useful with realtime indexes.
- Added a new partial option, `Postfix`, with an option, `from`. With `from: -4` and a word like `octopus`, will generate partials `[:octopus, :octopu, :octop, :octo]` (until -4).
New default option is `Postfix.new(from: -3)`, not `Substring.new(from: -3, to: -1)` anymore. The two options are identical in function.
- Only Picky's tokenizers call `to_s` on data anymore. This means that you can write tokenizers that work on whatever kind of object you like. The Picky standard tokenizers themselves ensure that they get to work with a string.
- Fix for `Substring` partialization, when negative `from` and `to` options are used at the same time.
- Experimental exchangeable backends.

###### Project

- RSpec 1 has been updated to RSpec 2.

## 3.2.0

This release includes BREAKING changes. See below.

###### [Server](https://github.com/floere/picky/tree/master/server)

- Removed bundler specific code from Picky. You can now decide yourself if you want it. Opens the possibility to just run Picky in a script to try ideas etc. (see example gist: [https://gist.github.com/1315618](https://gist.github.com/1315618)).

###### [Generators](https://github.com/floere/picky/tree/master/generators)

- The generated Sinatra server does not use bundler anymore. Classic servers (might) still need it. You can add it back in by adding the following code in `app.rb`, right after `require 'picky'`:

        begin
          require 'bundler'
        rescue LoadError => e
          require 'rubygems'
          require 'bundler'
        end
        Bundler.setup PICKY_ENVIRONMENT
        Bundler.require

## 3.1.13

###### [Generators](https://github.com/floere/picky/tree/master/generators)

- `picky generate` will not display the error backtrace part anymore.

## 3.1.12

###### [Server](https://github.com/floere/picky/tree/master/server)

- Runtime indexing (`remove`, `add`, `replace`) now possible on a single category. Please use e.g. `index[:category_name].add some_object_with_id_and_category_name_method`.

## 3.1.11

###### [Server](https://github.com/floere/picky/tree/master/server)

- See last release. This release adds support for similarity searches on a realtime index.
- Please only use realtime indexing for experimental purposes.

## 3.1.10

###### [Server](https://github.com/floere/picky/tree/master/server)

- This release holds an *experimental* release of realtime indexing for 3.2: An index now supports `#add(object_responding_to_id_and_categories)`, `#remove(id_of_added_object)`, `#replace(object_responding_to_id_and_categories)`. Replace is simply remove+add. Replacing a non-existent object behaves like an add. I suggest using solely `replace`. Notes: Only works in single-process, single-threaded servers. Does not persist. Only yet works when starting from an empty index, e.g. `source []`.
- Please only use realtime indexing for experimental purposes.

## 3.1.9

###### [Server](https://github.com/floere/picky/tree/master/server)

- Rewrite of "rake index" – Picky will only fork processes if there is the capability to fork (i.e. not Windows), or if there are more than one processor available.

## 3.1.8

###### [Server](https://github.com/floere/picky/tree/master/server)

- Possible solution to [Issue 32](http://github.com/floere/picky/issues/32). The issue is possibly related to [http://redmine.ruby-lang.org/issues/5003](http://redmine.ruby-lang.org/issues/5003). (Windows users, please use the next version, 3.1.9)

## 3.1.7

###### [Client](https://github.com/floere/picky/tree/master/client)

- Fixed scrolling after "More Results". Will scroll to the top of the newly added results, instead of to the last header of the newly added results. Get the new minified version here: [https://github.com/floere/picky/tree/master/client/javascripts](https://github.com/floere/picky/tree/master/client/javascripts).

## 3.1.6

###### [Client](https://github.com/floere/picky/tree/master/client)

- Javascripts fixed. Get the new minified version here: [https://github.com/floere/picky/tree/master/client/javascripts](https://github.com/floere/picky/tree/master/client/javascripts).

###### [Server](https://github.com/floere/picky/tree/master/server)

- Number of cores for OS Lion correctly reported.

## 3.1.5

###### [Server](https://github.com/floere/picky/tree/master/server)

- New Search block option: `ignore_unassigned_tokens(truey/falsy)`. Default is false. If true, will ignore tokens that cannot be assigned to any category. If you search for example for `"Picky Garblegarblegarble"`, and `"Garblegarblegarble"` isn't in any index, then it will return result _as if_ `"Garblegarblegarble"` hadn't been there. In this case, it will just return something like searchengine:"picky".

## 3.1.4

###### [Server](https://github.com/floere/picky/tree/master/server)

- Don't fork if there's just one index to be processed.

## 3.1.3

###### [Server](https://github.com/floere/picky/tree/master/server)

- Added `#ignore` option to `Search` definition block. Calling `ignore :name` will ignore tokens in allocations that are mapped to the name category. Example: You search for "David Hasselhoff". If Picky maps this to allocations `[ [:first_name, name], [:first_name, :movie_title] ]`, only `[ [:first_name], [:first_name, :movie_title] ]` will survive. The `Hasselhoff - name` match will simply be ignored.

## 3.1.2

###### Generated Client

- The `before` Javascript callback option given to the `PickyClient` has changed signature and how it is called. Old was `before(params, query)`, and the returned params changed the params. This did not allow changing the `query` in the callback. New is `before(query, params)` and the returned `query` replaces the query given as parameter. This allows changing the query before sending it off. The params can be changed as well, using `params['option'] = value;`.

## 3.1.1

###### [Server](https://github.com/floere/picky/tree/master/server)

- `rake index` does not fork anymore if there's just one index to be indexed.
- Experimental `Picky::Partial::Infix` partial generator. Use to find all possible substrings inside words. Options are `min`, `max`, both take negative and/or positive values. Negative values indicate length up to length - X. E.g. `min: 3, max: -1 # :hello => [:hello, :hell, :ello, :hel, :ell, :llo]`
- Experimental `Picky::Backends::File` file backend. Use in index definition block as follows: `backend Picky::Backends::File.new`. Use if you don't want Picky to use as much memory. Performance penalty applies.

## 3.1.0

This release includes BREAKING changes. See below.

###### [Server](https://github.com/floere/picky/tree/master/server)

- Exchangeable backends. New index definition: `Indexes::Memory` and `Indexes::Redis` are now unified in `Index`. So use `index = Picky::Index.new(name)` from now on. (See next point)
- A new option has been added to the index, `backend`. It takes a backend instance, making the backend exchangeable. The default is the memory backend, which you do not need to set. If you want a Redis backend, use as follows: `index = Index.new(name) { backend Picky::Backends::Redis.new }`. If you want to explicitly set the memory backend: `index = Index.new(name) { backend Picky::Backends::Memory.new }`.
- Unified tokenizers. Method `#tokenize(text)` now returns `[ ["token", "token", "token"], ["Original", "Original", "Original"] ]`. So your own tokenizer only needs to adhere to this interface and can be passed to the index/search using the `indexing`/`searching` method.
- Removed tokenizer option `removes_characters_after_splitting: /some regexp/` (without replacement).

## 3.0.1

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fixed & integration tested rake tasks (Thanks rogerbraun!)

## 3.0.0

This release includes BREAKING changes. See below. (Here we start with this style of BREAKING notation)

###### [Client](https://github.com/floere/picky/tree/master/client)

- BREAKING Removed method `Picky::Convenience#allocations_size`. Use `#allocations.size`.

###### [Server](https://github.com/floere/picky/tree/master/server)

- BREAKING Removed `Results#to_log`. `Results#to_s` returns a log worthy string now.
- See changes in pre versions for complete changelog on 3.0.

## 3.0.0.pre5

###### [Server](https://github.com/floere/picky/tree/master/server)

- Renamed Picky::Result#serialize -> Picky::Result#to_hash.

## 3.0.0.pre4

###### [Generators](https://github.com/floere/picky/tree/master/generators)

- Added an All-In-One (Client + Server) Sinatra web app. This proves useful when wishing to use Picky on Heroku.

## 3.0.0.pre3

###### [Client](https://github.com/floere/picky/tree/master/client)

- Gemfile referred to version ~> 2.0 instead of = 3.0.0.pre2.

## 3.0.0.pre2

###### [Server](https://github.com/floere/picky/tree/master/server)

- Breaking: Index::Memory and Index::Redis do not accept options anymore.

  Define options in the block or on the resulting instances

    some_index = Indexes::Memory.new(:some_name) do
      source ...
      key_format ...
      category ...
      category ...
      category ...
      result_identifier ...
    end

- Breaking: PickyLog removed.

  In the classic server, use

    Picky.logger = Logger.new 'log/search.log'

  if you want to log (uses SomeLogger#info).

  In the Sinatra server, use

    MyLogger = Logger.new 'log/search.log'
    ...
    get '/path' do
      result = ...
      MyLogger.info result.to_log(params[:query]) if you want to log.
      result.to_json
    end

- Breaking: app/logging.rb not loaded anymore. You have to require it yourself if you want that.
- A missing source is only noticed when it is used (such as in indexing). This makes it possible to set a source at a later time.

## 3.0.0.pre1

###### [Server](https://github.com/floere/picky/tree/master/server)

- Note: The key_format is not saved in the index configuration anymore.

###### [Generators](https://github.com/floere/picky/tree/master/generators)

- New example server, sinatra_server. The new default, very flexible.

## 2.7.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- Breaking: Method `#take_snapshot` removed from Indexes/Index/Category (not needed anymore).
- Breaking: Users need to reindex when installing this version (index "index" now identified by "inverted" to be more clear).
- Rake tasks rewritten to be simpler and clearer. Most notably, `index:specific[index,category]` is now just `index[index,category]` (both optional).
- Reindexing now possible in running server, also for ActiveRecord Arel sources.
- More verbose indexing output with file locations.
- Taking data snapshots improved.
- Fix for e.g. `picky search localhost:8080/books` if highline gem is missing (thanks tonini!).

## 2.6.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- Breaking: `Indexes#find` method has been removed. Use `Indexes[index_name]` and `Indexes[index_name][category_name]`.
- Breaking: `Index#index!`, `Index#cache!`, `Category#index!`, `Category#cache!` have been removed. Use `Indexes.index` (combines `index!` and `cache!`), or `Indexes[books].index`, or `Indexes[books][title].index`.
- Get Indexes/Categories using the `#[]` method. E.g. `Indexes[:books]` to get the `:books` index, and `Indexes[:books][:author]` to get the `:author` category of the `:books` index.
- `Indexes`, `Indexes[:some_index]`, and `Indexes[:some_index][:some_category]` now all support

  the following methods:
  * `#index` (just index: prepare data and cache data)
  * `#reload` (just reload the cached data into the server, no effect on Redis indexes)
  * `#reindex` (index and reload one category after another)

  Note: `#reload` and `#reindex` only make sense in a running server with memory indexes.

  Examples:
  * `Indexes.index` (index all indexes, randomly)
  * `Indexes[:some_index].reindex` (reindex that index)
  * `Indexes[:some_index][:some_category].reload` (just reload that category)

## 2.5.2

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fixed: Redis indexing. Old values are now removed on reindexing.

## 2.5.1

###### [Server](https://github.com/floere/picky/tree/master/server)

- Minor changes.

## 2.5.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- Searches can now search in multiple qualifiers, separating them by a ",". E.g. name,street:tyne.
- Searches will no longer search in all categories (fields) if a qualifier has been mistyped. So, namme:peter will not search in all categories, but instead return an empty result if category namme does not exist.

## 2.4.3

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fixed: Indexing a single category where a `#each` source was used using `rake index:specific[index,category]` raised an error.

## 2.4.2

###### [Server](https://github.com/floere/picky/tree/master/server)

- Live interface for picky-live gem fixed.

## 2.4.1

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fixes Redis indexing.

###### [Client](https://github.com/floere/picky/tree/master/client)

- Requires activesupport (thanks stanley!).

## 2.4.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- Added a configuration option `key_format` for index, categories. It sets the format that this index'/category's keys are in. Use as you would with `source`, as either method in the index block, as index parameter, or category parameter.

###### [Client](https://github.com/floere/picky/tree/master/client)

- The client is now finally really data driven by the server, see next changes.
- Added two options for the `PickyClient`, `fullResults` and `liveResults`. It designates how many results should be rendered. Defaults are for full: 20, and for live: 0.
- The `Convenience#ids` method now by default returns all ids returned from the server.
- The `Convenience#populate_with`'s second param is not the amount of populated ids anymore. Instead it populates all returned ids by default. If you want less, pass in the `up_to` option. So, e.g. `results.populate_with :up_to => 20`.

## 2.3.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- Integration specs in the server are now easy. In your specs, `require 'picky-client/spec'`. Example: `it { books.search('alan').ids.should == [259, 307, 449] }`.

###### [Generators](https://github.com/floere/picky/tree/master/generators)

- Added integration specs that use the above tests & matchers to the generated example app.

###### [Client](https://github.com/floere/picky/tree/master/client)

- Added `Picky::TestClient` which can be used in the server for integration specs. Use `Picky::TestClient.new(YourPickyApp, :path => '/your_search_url')`, then `test_client.search('bla', :ids => 12, :offset => 0).ids.should ==== [1,3,4]` or `test_client.search('blu bli').should have_categories(['title', 'author'], ['title', 'title'])` to test category result combinations and order.

## 2.2.1

###### [Server](https://github.com/floere/picky/tree/master/server)

- Very simple geo search that works best in temperate areas. If you're just looking for results that are close to yours, give it a go. Use `#geo_categories(lat, lng, radius_in_kilometers, options = {})`

## 2.2.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- (BREAKING CHANGE) Since I prefer the block style configuration for indexes, the source is now an optional parameter. Picky will tell you if you still use the old style. New is that you can define the source of an index in the block, e.g.: `Index::Memory.new(:some_index) do source Sources::CSV.new(...) end`
- Sources can now be anything that responds to #each and that returns objects that respond to #id. (That means you can just pass in an array, or MongoMapper or ActiveRecord's `Book.order('updated_at DESC')` or similar)
- The app/application.rb API has gotten a few aliases: `default_indexing` and `default_querying` can now be called with `indexing` or `searching`.
- Each index can now have its own indexing. Use e.g. `Index::Memory.new(:some_index) do indexing removes_characters: /[^a-z]/i end`.
- Each `Search` can now have its own "searching", e.g.: `Search.new(some_index) do searching removes_characters: /[^a-z]/i end`
- Added option for collaborators (on the Picky server) of setting the performance ratio if the performance specs fail too often. Just add a `spec/performance_ratio.rb` file with the content `module Picky; PerformanceRatio = x.xx end`. Less than 1.0 is more benign, more than 1.0 is harsher.

## 2.1.2

###### [Server](https://github.com/floere/picky/tree/master/server)

- Improved `rake search <url> [<result id amount>]` with better description and error handling.

## 2.1.1

###### [Server](https://github.com/floere/picky/tree/master/server)

- `rake search <url>`, a simple experimental terminal search interface.

## 2.1.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- Tokenizing completely rewritten. It works now almost the same in indexing and in querying, with the exception of downcasing (or not, for case sensitive searches).
- Indexing and querying now don't downcase anymore right at the beginning of processing, but rather after text preprocessing. For you this means that you need to use case insensitive regexps `/…/i` in the config if you need a case sensitive search (get it?).
- `default_indexing` and `default_querying` offer a new option, `case_sensitive`, which is by default `false`. Set it in indexing and querying to `true` to have your search be case sensitive (usually it is a good idea to set them both to the same case sensitivity). Watch the regexp options – possibly best if you set them to case insensitive `/…/i`.

## 2.0.0

- Let's go live, wohoo! :) See the prerelease history notes for all changes.

## 2.0.0.pre3

###### [Server](https://github.com/floere/picky/tree/master/server)

- Renamed `Similarity::DoubleLevenshtone` (aka `Similarity::Phonetic`) to `Similarity::DoubleMetaphone` (BREAKING: Cannot use `Similarity::Phonetic` anymore).
- Added `Similarity::Soundex`.
- Added `Similarity::Metaphone`.

## 2.0.0.pre2

###### [Client](https://github.com/floere/picky/tree/master/client)

- Asterisks are correctly escaped before saved in the browser history.
- you: Give feedback, thanks! :)

## 2.0.0.pre1

- New major version number – see reasons for API change: [http://florianhanke.com/blog/2011/03/16/pickys-adolescence.html](http://florianhanke.com/blog/2011/03/16/pickys-adolescence.html).

###### [Server](https://github.com/floere/picky/tree/master/server)

- (Breaking change) `Query::Full` and `Query::Live` have been replaced by just `Search`. So what you now do is `route /something/ => Search.new(index1, index2, ..., options)`.
- Pass in the `ids` param to define the amount of result ids you'd like. This is how you'd do it with curl: `curl 'localhost:8080/books?query=test&ids=20'`. 20 ids is the default.

###### [Client](https://github.com/floere/picky/tree/master/client)

- (Breaking change) `Picky::Client::Full` and `Picky::Client::Live` have been replaced by `Picky::Client`. New option: `ids`. Pass in to define the amount of `ids` you'd like. For a live query you need none, so pass in 0. (20 is the default in the server)
- See client changes above. Replace `Picky::Client::Full` and `Picky::Client::Live` with just a single `Picky::Client` instance with the same options as before (but just a single URL on the server as desribed above).
- Added `rake javascripts`, `rake update` to the client and client project generator which copies the javascripts from the client gem into your directory. (If you have an old generated project, add `require 'picky-client/tasks'; Picky::Tasks::Javascripts.new` in your `Rakefile`)

###### Generated Servers

- See server changes above. Replace `Query::Full` and `Query::Live` instance pairs by just a single `Search` instance.

## 1.5.4

###### [Client](https://github.com/floere/picky/tree/master/client)

- Not breaking the web anymore ;) Using history.js instead of address.js to do away with the hash bang.

## 1.5.3

###### [Server](https://github.com/floere/picky/tree/master/server)

- `rake stats` and `rake analyze`. Get information about your app.

## 1.5.2

###### [Server](https://github.com/floere/picky/tree/master/server)

- When indexing from the database, the intermediary snapshot table is now called `"picky_#{index.identifier}_index"` instead of `"#{index.identifier}_type_index"` to be clearer that it is Picky creating these tables, and what it is. You can remove the ..._type_index tables.
- The database source now uses mostly AR adapter methods to make it more agnostic.

## 1.5.1

###### [Server](https://github.com/floere/picky/tree/master/server)

- Picky now traverses more cleanly over your database data. (Thanks Jason Botwick!)

## 1.5.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- Redis backend.
- The Redis backend uses db 15.
- The mysql gem is used by default.

## 1.4.3

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fix for non-working picky command line interface. (Thanks Jason Botwick!)

## 1.4.2 (Redis backend prerelease)

###### [Server](https://github.com/floere/picky/tree/master/server)

- Redis backend prototype.
- `rake index:specific[index]` or `rake index:specific[index,category]` to index just a specific index or category.
- Postgres source better handled.

## 1.4.1

###### [Client](https://github.com/floere/picky/tree/master/client)/[Generators](https://github.com/floere/picky/tree/master/generators)

- The `choices` option is now localized. If you have generated a new Picky project with 1.4.0, please do localize your `choices` like so: `choices:{ (formats here) }` => `choices:{en:{ (formats here) }}` and whatever locales you'd like to use.

## 1.4.0

###### [Client](https://github.com/floere/picky/tree/master/client)/[Generators](https://github.com/floere/picky/tree/master/generators)

- Latest Javascript PickyClient object includes the option to format the choices better, option `group: [['author', 'title', 'subjects'], ['publisher']]` lets you group certain categories together while option `choices: { 'title': format: "<strong>%1$s</strong>", filter: function(text) { return text.toUpperCase(); }, ignoreSingle: false }` lets you define how each combination is handled in detail. Again, hard to explain, easy to see. (see issue for details, closes [issue 9](https://github.com/floere/picky/issues/closed#issue/9)).
- Added a `wrapResults` options where you can define wrapper HTML bits that are wrapped around each allocation group of `<li>` results. The default is: `wrapResults: '<ol class="results"></ol>'`.
- Headers are now contracted, this means no more "written by florian and written by hanke", but "written by florian hanke". (closes [issue 10](https://github.com/floere/picky/issues/closed#issue/10))

###### [Client](https://github.com/floere/picky/tree/master/client)

- Split #interface method into => #input, #results, so that users can wrap each with custom elements. Don't forget to wrap into a div#picky.

###### [Generators](https://github.com/floere/picky/tree/master/generators)

- Example now constricts the Picky interface width using a div.content. Please use a wrapper div to constrict div#picky.
- Cleanup of Javascript code, inclusion of formerly external javascripts (`scrollTo`, `timer`, `jQuery 1.5`).
- Interface HTML structure refactor. Results should now be li-s. Result groups (combinations/allocations, around the result li-s) are each inside an ol.results. Please check your CSS files if they need to be adapted to the new structure.
- Cleanup of CSS, much more flexible and specific.

## 1.3.4

###### [Generators](https://github.com/floere/picky/tree/master/generators)/[Client](https://github.com/floere/picky/tree/master/client)

- In the generated Sinatra client, queries can be passed in through the query param q. Example: http://www.mysearch.com/?q=example
- In the generated sinatra client, the back/forward buttons work via jquery.address plugin. Closes github issue 6.

## 1.3.3

###### [Server](https://github.com/floere/picky/tree/master/server)/[Client](https://github.com/floere/picky/tree/master/client)

- Server now sends the similar word instead of the original in similarity tokens (semelor~ -> similar). Even if that means, that the original way of writing is not preserved (SEmElOr~ -> similar). We're trying to help people have good searches, so there.

## 1.3.2

- Fixed description in the "picky" command. Also now shows optional parameters more clearly.

## 1.3.1

###### [Server](https://github.com/floere/picky/tree/master/server)

- Ability to handle string/symbol keys (for future key/value store data sources).
- Live interface uses select instead of sleep in the master process.

## 1.3.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- Offers a new routing API, an interface that permits changing parameters in the running server. Use `route %r{/admin} => Live::Interface.new`.

###### [Statistics](https://github.com/floere/picky/tree/master/statistics)

- The statistics server is now called "Clam", a chain smoking friend of Picky's.

###### [Live](https://github.com/floere/picky/tree/master/live)

- A new Gem "picky-live" that offers a live interface into the Picky server, provided you have a route for it. It is called "Suckerfish", and is one of Picky's friends, too.

## 1.2.4

###### [Server](https://github.com/floere/picky/tree/master/server)

- `default_indexing` (in the application.rb) provides a new option `reject_token_if => some_lambda`, e.g.: `reject_token_if: lambda { |token| token.nil? || token == :hello }` where you can define which tokens go into the index, and which do not. Default lambda is: `&:empty?`. This means that only non-empty tokens are saved in the index. You could, for example, not save tokens that have length < 2 (since they might be too small for your purposes). Note that tokens are passed into the hash as symbols.

###### [Statistics](https://github.com/floere/picky/tree/master/statistics)

- Fixed a bug where the last line in the log file was counted once a second time after reloading the stats.
- Slight interface redesign.

## 1.2.3

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fixed a bug where the partial strategy `Partial::None` was not correctly used: A query like `Peter` did not return results even if "Peter" could be found using quotes: "Peter" (FYI, double quotes force Picky to use the exact index instead of the partial one. While, conversely, the asterisk* forces Picky to use the partial index instead of the exact one).

## 1.2.2

###### [Statistics](https://github.com/floere/picky/tree/master/statistics)

- Statistics server handles logfile reading in a cleaner way when the gem has been installed by root.

## 1.2.1

###### [Statistics](https://github.com/floere/picky/tree/master/statistics)

- (BETA) New statistics gem for Picky. Run `picky stats path/to/your/search.log [port]` to start a statistics server. Go to [http://localhost:4567](http://localhost:4567) after running the command to take a look.

## 1.2.0

###### [Client](https://github.com/floere/picky/tree/master/client)

- (BREAKING) Picky::Client::Base.search(:query => 'bla') has changed to Picky::Client::Base.search('bla'), as the query itself is not optional. The rest of the options is still passed in as a Hash through the second parameter.

## 1.1.7 (1.2.0 pre)

###### [Server](https://github.com/floere/picky/tree/master/server)

- Redefined API for 1.1.6 beta feature, ranged search.

###### Documentation

- API for #define_ranged_category.

## 1.1.6

###### [Server](https://github.com/floere/picky/tree/master/server)

- Enabled beta feature "low/high limited range search", see [API RDoc](http://floere.github.com/picky/doc/index.html) (IndexAPI class).

## 1.1.5

###### [Server](https://github.com/floere/picky/tree/master/server)

- Passing in a similarity search (e.g. with text "hello") will never return "hello" as a similar token.

## 1.1.4

###### [Generators](https://github.com/floere/picky/tree/master/generators)

- Removed unnecessary jquery-1.3.2 from client, since it wasn't referenced anyway.

## 1.1.3

###### [Server](https://github.com/floere/picky/tree/master/server)

- The CouchDB source now uses a little trick/hack to make its ids work in Picky. They are translated into decimal numbers from its hex string representations. Recalculate using #to_s(16) before getting objects from CouchDB in a webapp.

## 1.1.2

###### [Generators](https://github.com/floere/picky/tree/master/generators)

- Added generator for empty unicorn projects, use `picky generate empty_unicorn_project <project_name>` to generate one.

## 1.1.1

###### [Server](https://github.com/floere/picky/tree/master/server)/[Client](https://github.com/floere/picky/tree/master/client)

- Removed generator projects that have been moved to picky-generators. Gems now much smaller :)

## 1.1.0

###### [Server](https://github.com/floere/picky/tree/master/server)/[Client](https://github.com/floere/picky/tree/master/client)

- Generators extracted into picky-generators gem.

###### [Generators](https://github.com/floere/picky/tree/master/generators)

- Generators and example projects for both server and client.

## 1.0.0

- Lots of [API RDoc](http://floere.github.com/picky/doc/index.html).
- Yaaaay! Finally :)

## 0.12.3 (1.0.0 pre4)

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fixed cased file name (led to problems under Linux, thanks Bernd Schoeller)

## 0.12.2 (1.0.0 pre3)

###### [Server](https://github.com/floere/picky/tree/master/server)

- New :from option. Assume you have a source `Sources::CSV.new(:title, file:'some_file.csv')` but you want the category to be called differently. Use the from option as follows: `define_category(:similar_title, :from => :title)`.
- CSV source uses `FasterCSV`, passing through all its options (`col_sep`, `row_sep` et cetera).
- More understandable output for rake try, rake try:index, rake try:query.

## 0.12.1 (1.0.0 pre2)

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fixed a bug where the default qualifier definition (like the author in the query author:tolkien) for categories were ignored.

## 0.12.0 (1.0.0 pre1)

###### [Server](https://github.com/floere/picky/tree/master/server)

- API change in application.rb: Use #define_category instead of #category on an index. (category still possible, but deprecated)
- Internal rewrite.

## 0.11.2

###### [Server](https://github.com/floere/picky/tree/master/server)

- Rake task index:check will check if all necessary index files are generated. (Nice to use before restarting.)

## 0.11.1

###### [Server](https://github.com/floere/picky/tree/master/server)

- Better error reporting in Rake tasks. Task naming improved.
- Internal cleanup.

## 0.11.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- Major API and internals rewrite. See generated project for help.

## 0.10.5

###### [Server](https://github.com/floere/picky/tree/master/server)

- Source CouchDB added (thanks to github.com/stanley).

## 0.10.4

###### [Server](https://github.com/floere/picky/tree/master/server)

- Typo fixed (thanks to github.com/stanley).

## 0.10.3

###### [Client](https://github.com/floere/picky/tree/master/client)

- Helpful configuration page in the client at /configure.

## 0.10.2

###### [Server](https://github.com/floere/picky/tree/master/server)

- Phonetic similarity (e.g. lyterature~) available through Similarity::Phonetic.new(4), see example.

## 0.10.1

###### [Server](https://github.com/floere/picky/tree/master/server)

- :weights option for queries also ok in the form: { [:cat1, :cat2] => 4 }, where 4 is any weight.

## 0.10.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- (BREAKING) Total rewrite/exploration of the Application API.
           Stay on 0.9.4 if you don't want to update right now.
- Character substitution now configurable. Default is no character substitution.

## 0.9.4

###### [Server](https://github.com/floere/picky/tree/master/server)

- rake routes: Shows all current URL paths, and if they are processable fast.

## 0.9.3

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fixed: Querying parameters are not ignored anymore.

## 0.9.2

###### [Client](https://github.com/floere/picky/tree/master/client)

- Fixed result_hash.entries to return the right amount of entries.
- The result_hash#entries now takes a block and replaces the e.g. AR instances with e.g rendered results.
- Locale handling fixed. Uses the locale of the HTML tag by default.

## 0.9.1

###### [Server](https://github.com/floere/picky/tree/master/server)

- Delicious missing gem notice if www-delicious gem is missing.
-Partial::Subtoken renamed to Partial::Substring.
             Options: down_to -> from, starting_at -> to
- Index bundle file handling extracted into specific Index::Files backend.

## 0.9.0

###### [Server](https://github.com/floere/picky/tree/master/server)/[Client](https://github.com/floere/picky/tree/master/client)

- Jump to 0.9.0 to work on API, release 1.0.0 soon.

###### [Server](https://github.com/floere/picky/tree/master/server)

- Partial indexing now only down to -3, e.g. florian -> partial: floria, flori, flor.
             If you want down_to the first character (florian, floria, flori, flor, flo, fl, f), use:
             field(:some_field_name, :partial => Partial::Subtoken.new(:down_to => 1))
- Sources::Delicious.new(user, pass) for indexing your delicious posts.
- indexing and querying config now done on tokenizer instances.

## 0.3.1

###### [Server](https://github.com/floere/picky/tree/master/server)

- Generator gives more informative NoGeneratorError message.

## 0.3.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- Uses json (index, index weights) and marshal (similarity index) to dump indexes.
- Generator is more helpful (thanks to github.com/kschiess)
- Generator for a Sinatra project. (picky-client sinatra project_name <- Note: Changed to picky generate sinatra_client project_name)

###### [Client](https://github.com/floere/picky/tree/master/client)

- Helpful generator. (thanks to github.com/kschiess)

## 0.2.4

###### [Server](https://github.com/floere/picky/tree/master/server)

- Indexing output, output in general cleaned up.
- Better info after generating a new project (thanks kschiess).
- Indexer now uses json for the dump files (much faster, slightly larger, thanks to github.com/niko).

###### [Client](https://github.com/floere/picky/tree/master/client)

- JS files rewritten.

## 0.2.3

###### [Server](https://github.com/floere/picky/tree/master/server)

- Explicit index buffering: Indexer hits filesystem only seldomly.
- Internal rename from full index to exact index (visible in index filenames).
- Solr Indexing removed until someone needs it. Then we'll talk cash. Just kidding.
- Improved Gemfile.

## 0.2.2

###### [Server](https://github.com/floere/picky/tree/master/server)

- Umlaut handling (i.e. character substitution) now pluggable.
- Apps finalization now handled through Ruby callback (thanks to github.com/severin).

## 0.2.1

###### [Server](https://github.com/floere/picky/tree/master/server)

- Fix for negative partial index values (:partial => Partial::Subtoken.new(:down_to => -3))

## 0.2.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- Only uses JSON to encode results.

###### [Client](https://github.com/floere/picky/tree/master/client)

- Only uses JSON for full and partial queries.

## 0.1.0

###### [Server](https://github.com/floere/picky/tree/master/server)

- Application interface rewrite. See a freshly created
  project (using picky project <name> <- Note: Renamed picky generate unicorn_server <name>).
  Application#add_index.

## 0.0.9

###### [Client](https://github.com/floere/picky/tree/master/client)

- Cleanup. Frontend example.

## 0.0.8

###### [Server](https://github.com/floere/picky/tree/master/server)

- Application#add_index instead of Application#type.
- Simplified scaffolding.

## 0.0.7

###### [Server](https://github.com/floere/picky/tree/master/server)

- Gem compiles on install. Do not compile on run.

## 0.0.6

###### [Server](https://github.com/floere/picky/tree/master/server)

- Removed unnecessary gem dependencies (thanks to niko).
- Added CSV to the possible Sources. Sources::CSV.new(:title, :author, :isbn, :file => 'data/books.csv'),
- Renamed all instances of SEARCH_* constants to PICKY_*. (Uses RACK_ENV)

## 0.0.5

###### [Server](https://github.com/floere/picky/tree/master/server)

- config.ru, unicorn.ru now top level in newly created project (more standard).
- Port now defined in unicorn.ru (use listen 'host:port').

###### [Client](https://github.com/floere/picky/tree/master/client)

- Enriched callbacks in the JS interface definition (before, success, after).

## 0.0.4

###### [Client](https://github.com/floere/picky/tree/master/client)

- Interface now created using Picky::Helper.interface or .cached_interface (if you only have a single language in your app).

## 0.0.3

###### [Server](https://github.com/floere/picky/tree/master/server)

- C-Code cleaned up, removed warnings.

## 0.0.2

###### [Server](https://github.com/floere/picky/tree/master/server)

- Newly created application better documented.

## 0.0.1

###### [Server](https://github.com/floere/picky/tree/master/server)/[Client](https://github.com/floere/picky/tree/master/client)

- Initial project. Server (picky) and basic frontend client (picky-client) available.
