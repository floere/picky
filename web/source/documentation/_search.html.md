## Search{#search}

{.edit}
[edit](http://github.com/floere/picky/blob/master/web/source/documentation/_search.html.md)

Picky offers a `Search` interface for the indexes. You instantiate it as follows.

Just searching over one index:

    books = Search.new books_index # searching over one index

Searching over multiple indexes:

    media = Search.new books_index, dvd_index, mp3_index

Such an instance can then search over all its indexes and returns a `Picky::Results` object:

    results = media.search "query", # the query text
                                20, # number of ids
                                 0  # offset (for pagination)

Please see the part about [Results](#results) to know more about that.

### Options{#search-options}

You use a block to set search options:

    media = Search.new books_index, dvd_index, mp3_index do
      searching tokenizer_options_or_tokenizer
      boost [:title, :author] => +2,
            [:author, :title] => -1
    end

#### Searching / Tokenizing{#search-options-searching}

See [Tokenizing](#tokenizing) for tokenizer options.

#### Boost{#search-options-boost}

The `boost` option defines what combinations to boost.

This is unlike boosting in most other search engines, where you can only boost a given field. I've found it much more useful to boost combinations.

For example, you have an index of addresses. The usual case is that someone is looking for a street and a number. So if Picky encounters that combination (in that order), it should move these results to a more prominent spot.
But if it thinks it's a street number, followed by a street, it is probably wrong, since usually you search for "Road 10", instead of "10 Road" (assuming this is the case where you come from).

So let's boost `street, streetnumber`, while at the same time deboost `streetnumber, street`:

    addresses = Picky::Search.new address_index do
      boost [:street, :streetnumber] => +2,
            [:streetnumber, :street] => -1
    end

If you still want to boost a single category, check out the [category weights option](#indexes-categories-weights).
For example:

    Picky::Index.new :addresses do
      category :street, weights: Picky::Weights::Logarithmic.new(+4)
      category :streetnumber
    end

This boosts the weight of the street category alone.

##### Note on Boosting

Picky combines consecutive categories in searches for boosting. So if you search for "star wars empire strikes back", when you defined `[:title] => +1`, then that boosting is applied.

Why? In earlier versions of Picky we found that boosting specific combinations is less useful than boosting a specific _order_ of categories.

Let me give you an example from a movie search engine. instead of having to say `boost [:title] => +1, [:title, :title] => +1, [:title, :title, :title] => +1`, it is far more useful to say "If you find any number of title words in a row, boost it". So, when searching for "star wars empire strikes back 1979", it is less important that it is exactly 5 title categories in a row that a title followed by the release year. In this case, the boost `[:title, :release_year] => +3` would be applied.

#### Ignore Categories{#search-options-ignore}

There's a [full blog post](http://florianhanke.com/blog/2011/09/01/picky-case-study-location-based-ads.html) devoted to this topic.

In short, the `ignore :category_name` option makes Picky throw away any result combinations that have the named category in it.

If Picky finds the tokens "florian hanke" in both `:first_name, :last_name` and `:last_name, :last_name`, and we've instructed it to ignore `first_name`,

    names = Picky::Search.new name_index do
      ignore :first_name
    end

then it will throw away the solutions for `:first_name, :last_name` (eg. "Peter Miller") and only use `:last_name, :last_name` (eg. "Smith Miller").

#### Ignore Unassigned Tokens{#search-options-unassigned}

There's a [full blog post](http://florianhanke.com/blog/2011/09/05/picky-ignoring-unassigned-tokens.html) devoted to this topic.

In short, the `ignore_unassigned_tokens true/false` option makes Picky be very lenient with your queries. Usually, if one of the search words is not found, say in a query "aston martin cockadoodledoo", Picky will return an empty result set, because "cockadoodledoo" is not in any index, in a car search, for example.

By ignoring the "cockadoodledoo" that can't be assigned sensibly, you will still get results.

This could be used in a search for advertisements that are shown next to the results.

If you've defined an ads search like so:

    ads_search = Search.new cars_index do
      ignore_unassigned_tokens true
    end

then even if Picky does not find anything for "aston martin cockadoodledoo", it will find an ad, simply ignoring the unassigned token.

#### Maximum Allocations{#search-options-maxallocations}

The `max_allocations(integer)` option cuts off calculation of allocations.

What does this mean? Say you have code like:

    phone_search = Search.new phonebook do
      max_allocations 1
    end

And someone searches for "peter thomas".

Picky then generates all possible allocations and sorts them.

It might get

* `[first_name, last_name]`
* `[last_name, first_name]`
* `[first_name, first_name]`
* etc.

with the first allocation being the most probable one.

So, with `max_allocations 1` it will only use the topmost one and throw away all the others.

It will only go through the first one and calculate only results for that one. This can be used to speed up Picky in case of exploding amounts of allocations.

#### Early Termination{#search-options-terminateearly}

The `terminate_early(integer)` or `terminate_early(with_extra_allocations: integer)` option stops Picky from calculate all ids of all allocations.

However, this will also return a wrong total.

So, important note: Only use when you don't display a total.

Examples:

Stop as soon as you have calculated enough ids for the allocation.

    phone_search = Search.new phonebook do
      terminate_early # The default uses 0.
    end

Stop as soon as you have calculated enough ids for the allocation, and then calculate 3 allocations more (for example, to show to the user).

    phone_search = Search.new phonebook do
      terminate_early 3
    end

There's also a hash form to be more explicit. So the next coder knows what it does. (However, us cool Picky hackers _know_ ;) )

    phone_search = Search.new phonebook do
      terminate_early with_extra_allocations: 5
    end

This option speeds up Picky if you don't need a correct total.