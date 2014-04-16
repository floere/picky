## Servers / Applications{#servers}

{.edit}
[edit](http://github.com/floere/picky/blob/master/web/source/documentation/_servers.html.md)

Picky, from version 3.0 onwards, is designed to run *anywhere*, *in anything*. An octopus has eight legs, remember?

This means you can have a Picky server running in a DRb instance if you want to. Or in irb, for example.

We do run and test the Picky server in two styles, [Classic and Sinatra](#servers-classicvssinatra).

But don't let that stop you from just using it in a class or just a script. This is a perfectly ok way to use Picky:

    require 'picky'
    
    include Picky # So we don't have to type Picky:: everywhere.
    
    books_index = Index.new(:books) do
      source Sources::CSV.new(:title, :author, file: 'library.csv')
      category :title
      category :author
    end
    
    books_index.index
    books_index.reload
    
    books = Search.new books_index do
      boost [:title, :author] => +2
    end
    
    results = books.search "test"
    results = books.search "alan turing"
    
    require 'pp'
    pp results.to_hash
    
More *Ruby*, more *power* to you!

### Sinatra Style{#servers-sinatra}

A [Sinatra](http://sinatrarb.com) server is usually just a single file. In Picky, it is a top-level file named

    app.rb

We recommend to use the [modular Sinatra style](http://www.sinatrarb.com/intro#Serving%20a%20Modular%20Application) as opposed to the [classic style](http://www.sinatrarb.com/intro#Using%20a%20Classic%20Style%20Application%20with%20a%20config.ru). It's possible to write a Picky server in the classic style, but using the modular style offers more options.

    require 'sinatra/base'
    require 'picky'
    
    class BookSearch < Sinatra::Application
    
      books_index = Index.new(:books) do
        source { Book.order("isbn ASC") }
        category :title
        category :author
      end
    
      books = Search.new books_index do
        boost [:title, :author] => +2
      end
    
      get '/books' do
        results = books.search params[:query],
                               params[:ids]    || 20,
                               params[:offset] ||  0
        results.to_json
      end
    
    end

This is already a complete Sinatra server.

#### Routing{#servers-sinatra-routing}

The Sinatra Picky server uses the same routing as Sinatra (of course). [More information on Sinatra routing](http://www.sinatrarb.com/intro#Routes).

If you use the server with the picky client software (provided with the picky-client gem), you should return JSON from the Sinatra `get`.
Just call `to_json` on the returned results to get the results in JSON format.

    get '/books' do
      results = books.search params[:query], params[:ids] || 20, params[:offset] ||  0
      results.to_json
    end

The above example search can be called using for example `curl`:

    curl 'localhost:8080/books?query=test'

#### Logging{#servers-sinatra-logging}

TODO Update this section.

This is one way to do it:

    MyLogger = Logger.new "log/search.log"
    
    # ...
    
    get '/books' do
      results = books.search "test"
      MyLogger.info results
      results.to_json
    end

or set it up in separate files for different environments:

    require "logging/#{PICKY_ENVIRONMENT}"

Note that this is not Rack logging, but Picky search engine logging. The resulting file can be used with the picky-statistics gem.

### All In One (Client + Server){#servers-allinone}

The All In One server is a Sinatra server and a Sinatra client rolled in one.

It's best to just generate one and look at it:

    picky generate all_in_one all_in_one_test

and then follow the instructions.

When would you use an All In One server? One place is [Heroku](http://heroku.com), since it is a bit more complicated to set up two servers that interact with each other.

It's nice for small convenient searches. For production setups we recommend to use a separate server to make everything separately cacheable etc.
