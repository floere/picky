## Tokenizing{#tokenizing}

{.edit}
[edit](http://github.com/floere/picky/blob/master/web/source/documentation/_tokenizing.html.md)

The `indexing` method in an `Index` describes how *index data* is handled.

The `searching` method in a `Search` describes how *queries* are handled.

This is where you use these options:

    Picky::Index.new :books do
      indexing options_hash_or_tokenizer
    end

    Search.new *indexes do
      searching options_hash_or_tokenizer
    end
    
Both take either an options hash, your hand-rolled tokenizer, or a `Picky::Tokenizer` instance initialized with the options hash.

### Options{#tokenizing-options}

Picky by default goes through the following list, in order:

1. *substitutes_characters_with*: A character substituter that responds to `#substitute(text) #=> substituted text`
1. *removes_characters*: Regexp of characters to remove.
1. *stopwords*: Regexp of stopwords to remove.
1. *splits_text_on*: Regexp on where to split the query text, including category qualifiers.
1. *removes_characters_after_splitting*: Regexp on which characters to remove after the splitting.
1. *normalizes_words*: `[[/matching_regexp/, 'replace match \1']]`
1. *max_words*: How many words will be passed into the core engine. Default: `Infinity` (Don't go there, ok?).
1. *rejects_token_if*: `->(token){ token == 'hello' }`
1. *case_sensitive*: `true` or `false`, `false` is default.
1. *stems_with*: A stemmer, ie. an object that responds to `stem(text)` that returns stemmed text.

You pass the above options into

    Search.new *indexes do
      searching options_hash
    end

You can provide your own tokenizer:

    Search.new books_index do
      searching MyTokenizer.new
    end

TODO Update what the tokenizer needs to return.

The tokenizer needs to respond to the method `#tokenize(text)`, returning a `Picky::Query::Tokens` object. If you have an array of tokens, e.g. `[:my, :nice, :tokens]`,
you can pass it into `Picky::Query::Tokens.process(my_tokens)` to get the tokens and return these.

`rake 'try[text,some_index,some_category]'` (`some_index`, `some_category` optional) tells you how a given text is indexed.

It needs to be programmed in a performance efficient way if you want your search engine to be fast.

### Tokenizer{#tokenizing-tokenizer}

Even though you usually provide options (see below), you can provide your own:

    Picky::Index.new :books do
      indexing MyTokenizer.new
    end

The tokenizer must respond to `tokenize(text)` and return `[tokens, words]`, where `tokens` is an Array of processed tokens and `words` is an Array of words that represent the original words in the query (or as close as possible to the original words).

It is also possible to return `[tokens]`, where tokens is the Array of processed query words. (Picky will then just use the tokens as words)

#### Examples{#tokenizing-examples}
  
A very simple tokenizer that just splits the input on commas:

    class MyTokenizer
      def tokenize text
        tokens = text.split ','
        [tokens]
      end
    end
    
    MyTokenizer.new.tokenize "Hello, world!" # => [["Hello", " world!"]]

    Picky::Index.new :books do
      indexing MyTokenizer.new
    end

The same could have been achieved with this:

    Picky::Index.new :books do
      indexing splits_text_on: ','
    end

### Notes{#tokenizing-notes}

Usually, you use the same options for indexing and searching:
    
    tokenizer_options = { ... }
    
    index = Picky::Index.new :example do
      indexing tokenizer_options
    end
        
    Search.new index do
      searching tokenizer_options
    end

However, consider this example.
Let's say your data has lots of words in them that look like this: `all-data-are-tokenized-by-dashes`.
And people would search for them using spaces to keep words apart: `searching for data`.
In this case it's a good idea to split the data and the query differently.
Split the data on dashes, and queries on `\s`:

    index = Picky::Index.new :example do
      indexing splits_text_on: /-/
    end
    
    Search.new index do
      searching splits_text_on: /\s/
    end

The rule number one to remember when tokenizing is:
*Tokenized query text needs to match the text that is in the index.*

So both the index and the query need to tokenize to the same string:

* `all-data-are-tokenized-by-dashes` => `["all", "data", "are", "tokenized", "by", "dashes"]`
* `searching for data` => `["searching", "for", "data"]`

Either look in the `/index` directory (the "prepared" files is the tokenized data), or use Picky's `try` rake task:

    $ rake try[test]
    "test" is saved in the Picky::Indexes index as ["test"]
    "test" as a search will be tokenized as ["test"]
    
You can tell Picky which index, or even category to use: 
    
    $ rake try[test,books]
    $ rake try[test,books,title]