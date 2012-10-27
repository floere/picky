## Facets

Here's [the Wikipedia entry on facets](http://en.wikipedia.org/wiki/Faceted_classification). I fell asleep after about 5 words. Twice.

In Picky, categories are explicit slices over your index data. Picky facets are implicit slices over your category data.

What does "implicit" mean here?

It means that you didn't explicitly say, "My data is shoes, and I have these four brands: Nike, Adidas, Puma, and Vibram". 

No, instead you told Picky that your data is shoes, and there is a category "brand". Let's make this simple:

    index = Picky::Index.new :shoes do
      category :brand
      category :name
      category :type
    end
    
    index.add Shoe.new(1, 'nike', 'zoom', 'sports')
    index.add Shoe.new(2, 'adidas', 'speed', 'sports')
    index.add Shoe.new(3, 'nike', 'barefoot', 'casual')

With this data in mind, let's look at the possibilities:

### Index facets

Index facets are very straightforward.

You ask the index for facets and it will give you all the facets it has and how many:

    index.facets :brand # => { 'nike' => 2, 'adidas' => 1 }
    
The category type is a good candidate also:

    index.facets :type # => { 'sports' => 2, 'casual' => 1 }

What are the options?

* `at_least`: `index.facets :brand, at_least: 2 # => { 'nike' => 2 }`
* `counts`: `index.facets :brand, counts: false # => ['nike', 'adidas']`
* both options: `index.facets :brand, at_least: 2, counts: false # => ['nike']`

`at_least` only gives you facets which occur at least n times and `counts` tells the facets method whether you want the counts with the facets or not.

Pretty straightforward, right?

Search facets are quite similar:

### Search facets

Search facets work the exact same way as index facets and you can use them in the same way:

    search_interface.facets :brand # => { 'nike' => 2, 'adidas' => 1 }
    search_interface.facets :type # => { 'sports' => 2, 'casual' => 1 }
    search_interface.facets :brand, at_least: 2 # => { 'nike' => 2 }
    search_interface.facets :brand, counts: false # => ['nike', 'adidas']
    search_interface.facets :brand, at_least: 2, counts: false # => ['nike']

However, you can also filter the facets with a filter query option.

    shoes.facets :brand, filter: 'some filter query'

What does that mean?

Usually you want to use multiple facets in your interface.
For example, a customer might already have filtered by type "sports" because they are only interested in sports shoes.
Now you'd like to show them the remaining brands, so that they can filter on the remaining facets.

How do you do this?

Let's say we have an index as above, and a search interface to the index:

    shoes = Picky::Search.new index

Now, if the customer has already filtered for sports, you simply add the `filter` option:

    shoes.facets :brand, filter: 'type:sports' # => { 'nike' => 1, 'adidas' => 1 }

This will give you only 1 "nike" facet. If the customer filtered for "casual":

    shoes.facets :brand, filter: 'type:casual' # => { 'nike' => 1 }

then we'd only get the casual nike facet (from that one "barefoot" shoe).

If the customer has filtered for brand "nike" and type "sports", you'd get:

    shoes.facets :brand, filter: 'brand:nike type:sports' # => { 'nike' => 1 }
    shoes.facets :name, filter: 'brand:nike type:sports' # => { 'zoom' => 1 }

Playing with it is fun :)

See below for testing and performance tips.

### Testing How To

Let's say we have an index with some data:

    index = Picky::Index.new :people do
      category :name
      category :surname
    end
        
    person = Struct.new :id, :name, :surname
    index.add person.new(1, 'tom', 'hanke')
    index.add person.new(2, 'kaspar', 'schiess')
    index.add person.new(3, 'florian', 'hanke')

This is how you test facets:

#### Index Facets
    
    # We should find two surname facets. 
    #
    index.facets(:surname).should == {
      'hanke' => 2,  # hanke occurs twice
      'schiess' => 1 # schiess occurs once
    }
    
    # Only one occurs at least twice.
    #
    index.facets(:surname, at_least: 2).should == {
      'hanke' => 2
    }

#### Search Facets
    
    # Passing in no filter query just returns the facets
    #
    finder.facets(:surname).should == {
      'hanke' => 2,
      'schiess' => 1
    }
    
    # A filter query narrows the facets down.
    #
    finder.facets(:name, filter: 'surname:hanke').should == {
      'tom' => 1,
      'florian' => 1
    }
    
    # It allows explicit partial matches.
    #
    finder.facets(:name, filter: 'surname:hank*').should == {
      'fritz' => 1,
      'florian' => 1
    }

### Performance

Two rules:

1. Index facets are faster than filtered search facets. If you don't filter though, search facets are as fast as index facets.
1. Only use facets on data which are a good fit for facets – where there aren't many facets to the data.

A good example for a good fit would be brands of shoes.
There aren't many different brands (usually less than 100).

So this facet query

    finder.facets(:brand, filter: 'type:sports')

does not return thousands of facets.

Should you find yourself in a position where you have to use a facet query on uncontrolled data, eg. user entered data, you might want to cache the results:
    
    category = :name
    filter   = 'age_bracket:40'
    
    some_cache[[category, filter]] ||= finder.facets(category, filter: filter)