## Categories{#indexes-categories}

{.edit}
[edit](http://github.com/floere/picky/blob/master/web/source/documentation/_category.html.md)

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

### Option partial{#indexes-categories-partial}

The partial option defines if a word is also found when it is only *partially entered*. So, `Picky` will be found when typing `Pic`.

#### Partial Marker \*

The default partial marker is `*`, so entering `Pic*` will force `Pic` to be looked for in the partial index.

The last word in a query is always partial, by default. If you want to force a non partial search on the last query word, use `"` as in `last query word would be "partial"`, but here `partial` would not be searched in the partial index.

#### Setting the markers

By default, the partial marker is `*` and the non-partial marker is `"`. You change the markers by setting

* `Picky::Query::Token.partial_character = '\*'`
* `Picky::Query::Token.no_partial_character = '"'`

#### Default

You define this by this:

    category :some, partial: (some generator which generates partial words)

The Picky default is

    category :some, partial: Picky::Partial::Substring.new(from: -3)

You get this one by defining no partial option:

    category :some

The option `Partial::Substring.new(from: 1)` will make a word completely partially findable.

So the word `Picky` would be findable by entering `Picky`, `Pick`, `Pic`, `Pi`, or `P`.

#### No partials

If you don't want any partial finds to occur, use:

    category :some, partial: Partial::None.new

#### Other partials

There are four built-in partial options. All examples use "hello" as the token.

* `Partial::None.new` Generates no partials, using `*` will use exact word matching.
* `Partial::Postfix.new(from: startpos)` Generates all postfixes.

  * `from: 1` # => \["hello", "hell", "hel", "he", "h"\]
  * `from: 4` # => \["hello", "hell"\]

* `Partial::Substring.new(from: startpos, to: endpos)` Generates substring partials. `to: -1` is set by default.

  * `from: 1` # => \["hello", "hell", "hel", "he", "h"\]
  * `from: 4` # => \["hello", "hell"\]
  * `from: 1, to: -2` # => \["hell", "hel", "he", "h"\]
  * `from: 4, to: -2` # => \["hell"\]

* `Partial::Infix.new(min: minlength, max: maxlength)` Generates infix partials. `max: -1` is set by default.

  * `min: 1` # => \["hello", "hell", "ello", "hel", "ell", "llo", "he", "el", "ll", "lo", "h", "e", "l", "l", "o"\]
  * `min: 4` # => \["hello", "hell", "ello"\]
  * `min: 1, max: -2` # => \["hell", "ello", "hel", "ell", "llo", "he", "el", "ll", "lo", "h", "e", "l", "l", "o"\]
  * `min: 4, max: -2` # => \["hell", "ello"\]

The general rule is: The more tokens are generated from a token, the larger your index will be. Ask yourself whether you really need an infix partial index.

#### Your own partials

You can also pass in your own partial generators. How?

Implement an object which has a single method `#each_partial(token, &block)`. That method should yield all partials for a given token. Want to implement a (probably useless) random partial search? No problem.

Example:

You need an alphabetic index search. If somebody searches for a name, it should only be found if typed as a whole. But you'd also like to find it when just entering `a`, for `Andy`, `Albert`, etc.

    class AlphabeticIndexPartial
      def each_partial token, &block
        [token[0], token].each &block
      end
    end

This will result in "A" and "Andy" being in the index for "Andy".

Pretty straightforward, right?

### Option weights{#indexes-categories-weights}

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

### Option similarity{#indexes-categories-similarity}

The similarity option defines if a word is also found when it is typed wrong, or _close_ to another word. So, "Picky" might be already found when typing "Pocky~". (Picky will search for similar word when you use the tilde, ~)

You define this by this:

    category :some, similarity: Similarity::None.new

(This is also the default)

There are several built-in similarity options, like

    category :some, similarity: Similarity::Soundex.new
    category :this, similarity: Similarity::Metaphone.new
    category :that, similarity: Similarity::DoubleMetaphone.new

You can also pass in your own similarity generators. See [this article](http://florianhanke.com/blog/2011/08/15/picky-30-its-all-ruby-part-1.html) to learn more.

### Option qualifier/qualifiers (categorizing){#indexes-categories-qualifiers}

Usually, when you search for `title:wizard` you will only find books with "wizard" in their title.

Maybe your client would like to be able to only enter "t"wizard"". In that case you would use this option:

    category :some, qualifier: "t"

Or if you'd like more to match:

    category :some,
             qualifiers: ["t", "title", "titulo"]

(This matches "t", "title", and also the italian "titulo")

Picky will warn you if on one index the qualifiers are ambiguous (Picky will assume that the last "t" for example is the one you want to use).

This means that:

    category :some,  qualifier: "t"
    category :other, qualifier: "t"

Picky will assume that if you enter `t:bla`, you want to search in the `other` category.

Searching in multiple categories can also be done. If you have:

    category :some,  :qualifier => 's'
    category :other, :qualifier => 'o'

Then searching with `s,o:bla` will search for `bla` in both `:some` and `:other`. Neat, eh?

### Option from{#indexes-categories-from}

Usually, the categories will take their data from the reader or field that is the same as their name.

Sometimes though, the model has not the right names. Say, you have an italian book model, `Libro`. But you still want to use english category names.

    Index.new :books do
      source { Libro.order('autore DESC') }
    
      category :title,  :from => :titulo
      category :author, :from => :autore
      category :isbn
    end

### Option key_format{#indexes-categories-keyformat}

You almost never use this, as the key format will usually be the same for all categories, which is when you would define it on the index, [like so](#indexes-keyformat).

But if you need to, use as with the index.

    Index.new "books" do
      category :title,
               :key_format => :to_s
    end

### Option source{#indexes-categories-source}

You almost never use this, as the source will usually be the same for all categories, which is when you would define it on the index, "like so":#indexes-sources.

But if you need to, use as with the index.

    Index.new :books do
      category :title,
               source: some_source
    end

### User Search Options{#indexes-categories-searching}

Users can use some special features when searching. They are:

* Partial: `something*` (By default, the last word is implicitly partial)
* Non-Partial: `"something"` (The quotes make the query on this word explicitly non-partial)
* Similarity: `something~` (The tilde makes this word eligible for similarity search)
* Categorized: `title:something` (Picky will only search in the category designated as title, in each index of the search)
* Multi-categorized: `title,author:something` (Picky will search in title _and_ author categories, in each index of the search)
* Range: `year:1999-2012` (Picky will search all values in `Range.new(1999..2012)`)

These options can be combined (e.g. `title,author:funky~"`): This will try to find similar words to funky (like "fonky"), but no partials of them (like "fonk"), in both title and author. 

Non-partial will win over partial, if you use both, as in `test*"`.

Also note that these options need to make it through the [tokenizing](#tokenizing), so don't remove any of `*":,-`.

### Key Format (Format of the indexed Ids){#indexes-keyformat}

By default, the indexed data points to keys that are integers, or differently said, are formatted using `to_i`.

If you are indexing keys that are strings, use `to_s` – a good example are MongoDB BSON keys, or UUID keys.

The `key_format` method lets you define the format:

    Index.new :books do
      key_format :to_s
    end

The `Picky::Sources` already set this correctly. However, if you use an `#each` source that supplies Picky with symbol ids, you should tell it what format the keys are in, eg. `key_format :to_s`.

### Identifying in Results{#indexes-results}

By default, an index is identified by its *name* in the results. This index is identified by `:books`:

    Index.new :books do
      # ...
    end

This index is identified by `media` in the results:

    Index.new :books do
      # ...
      result_identifier 'media'
    end

You still refer to it as `:books` in e.g. Rake tasks, `Picky::Indexes[:books].reload`. It's just for the results.