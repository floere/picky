## All Ruby

{.edit}
[Edit](http://github.com/floere/picky/blob/master/web/source/documentation/_intro.html.md)

Never forget this: *Picky is all Ruby, all the time*!

Even though we only describe examples of classic and Sinatra style servers, Picky can be included directly in Rails, as a client or server. Or in DRb. Or in your simple script without HTTP. Anywhere you like, as long as it's Ruby, really.

To drive the point home, remember that Picky is mainly two pieces working together: An index, and a search interface on indexes.

The index normally has a source, knows how to tokenize data, and has a few data categories. And the search interface normally knows how to tokenize incoming queries. That's it:

    index = Picky::Index.new :people do
      source { People.all } 
      indexing splits_text_on: /[\s,-]/
      category :first
      category :last
      category :age, partial: Picky::Partial::None.new
    end
    
    people = Picky::Search.new index do
      searching splits_text_on: /[\s,-]/
    end
    results = people.search 'joe'
    puts results

You can put these pieces anywhere, independently.

## Transparency

Picky tries its best to be *transparent* so you can go have a look if something goes wrong. It wants you to *never feel powerless*.

All the indexes can be viewed in the `/index` directory of the project. They are waiting for you to inspect their JSONy goodness.
Should anything not work with your search, you can see how it is indexed in the actual indexes and change your indexing parameters accordingly.

Since all is Ruby, you can log as much data as you want to help you improve your search application until it's working perfectly.