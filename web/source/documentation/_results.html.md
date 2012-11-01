## Results{#results}

{.edit}
[edit](http://github.com/floere/picky/blob/master/web/source/documentation/_results.html.md)

Results are returned by the `Search` instance.

    books = Search.new books_index do
      searching splits_text_on: /[\s,]/
      boost [:title, :author] => +2
    end
    
    results = books.search "test"
    
    p results         # Returns results in log form.
    p results.to_hash # Returns results as a hash.
    p results.to_json # Returns results as JSON.

### Logging{#results-logging}

TODO Update with latest logging style and ideas on how to separately log searches.

Picky results can be logged wherever you want.

A Picky Sinatra server logs whatever to wherever you want:

    MyLogger = Logger.new "log/search.log"
    
    # ...
    
    get '/books' do
      results = books.search "test"
      MyLogger.info results
      results.to_json
    end

or set it up in separate files for different environments:

    require "logging/#{PICKY_ENVIRONMENT}"

A Picky classic server logs to the logger defined with the `Picky.logger=` writer.

Set it up in a separate `logging.rb` file (or directly in the `app/application.rb` file).

    Picky.logger = Picky::Loggers::Concise.new STDOUT

and the Picky classic server will log the results into it, if it is defined.

Why in a separate file? So that you can have different logging for different environments.

More power to you.

### Sorting{#results-sorting}

Picky results are always *sorted in the order of the data provided* by the data source.

So if you need different sort orders you have to define two indexes.

Why? This was a conscious design decision on my part. Usually, we do not need multiple sortings in a search application (I reckon around 95% of the cases). However, if you need it, you can.

TODO Example that shows how to have different result sorting depending on the category a result is found.