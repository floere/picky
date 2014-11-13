## Results{#results}


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

### Sorting{#results-sorting}

If no sorting is defined, Picky results will be *sorted in the order of the data provided* by the data source.

However, you can sort the results any way you want.

#### Arbitrary Sorting

You can define an arbitrary sorting on results by calling `Results#sort_by`.
It takes a block with a single parameter: The stored id of a result item.

This example looks up a result item via id and then takes the priority of the item to sort the results. 

```ruby
results.sort_by { |id| MyResultItemsHash[id].priority }
```

The results are only sorted within their allocation.
If you, for example, searched for `Peter`, and Picky allocated results in `first_name` and `last_name`, then each allocation's results would be sorted.

Picky is optimized: it only sorts results which are actually visible. So if Picky looks for the first 20 results, and the first allocation already has more than 20 results in it – say, 100 --, then it will only sort the 100 results of the first allocation. It will still calculate all other allocations, but not sort them.

#### Sorting Costs

* If you don't call `Results#sort_by`, then sorting incurs no costs.
* With arbitrary sorting, the cost incurred is proportional to the sorted results. So if an allocation has 1000 results in it, and you want 20 results, then all 1000 results from that allocation are sorted.
* The more complex your sorting is, the longer sorting takes. So we suggest precalculating a sort key if you'd like to sort it according to a complex calculation. For example you could have a sorting hash which knows for each id how its priority is:

```ruby
sort_hash = {
  1 => 10, # important
  2 => 100 # not so important
}
results.sort_by { |id| sort_hash[id] }
```

Note that in Ruby, a lower value => more to the front (the higher up in Picky).



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