## Integration

{.edit}
[edit](http://github.com/floere/picky/blob/master/web/source/documentation/_integration.html.md)

How do you integrate Picky in…?

### Rails

There are basically two basic ways to integrate Picky in Rails:

* Inside your Rails app
* With an external server

The advantage of the first setup is that you don't need to manage an external server. However, having a separate search server is much cleaner: You don't need to load the indexes on Rails startup as you just leave the search server running separately.

#### Inside your Rails app

If you just want a small search engine inside your Rails app, this is the way to go.

In `config/initializers/picky.rb`, add the following: (lots of comments to help you)

    # Set the Picky logger.
    #
    Picky.logger = Picky::Loggers::Silent.new
    # Picky.logger = Picky::Loggers::Concise.new
    # Picky.logger = Picky::Loggers::Verbose.new
    
    # Set up an index and store it in a constant.
    #
    BooksIndex = Picky::Index.new :books do
      # Our keys are usually integers.
      #
      key_format :to_i
      # key_format :to_s # From eg. Redis they are strings.
      # key_format ... (whatever method needs to be called on
      # the id of what you are indexing)
        
      # Some indexing options to start with.
      # Please see: http://florianhanke.com/picky/documentation.html#tokenizing
      # on what the options are.
      #
      indexing removes_characters: /[^a-z0-9\s\/\-\_\:\"\&\.]/i,
               stopwords:          /\b(and|the|of|it|in|for)\b/i,
               splits_text_on:     /[\s\/\-\_\:\"\&\/]/,
               rejects_token_if:   lambda { |token| token.size < 2 }
      
      # Define categories on your data.
      #
      # They have a lot of options, see:
      # http://florianhanke.com/picky/documentation.html#indexes-categories
      #
      category :title
      category :subtitle
      category :author
      category :isbn,
               :partial => Picky::Partial::None.new # Only full matches
    end
    
    # BookSearch is the search interface
    # on the books index. More info here:
    # http://florianhanke.com/picky/documentation.html#search
    # 
    BookSearch = Picky::Search.new BooksIndex

    # We are explicitly indexing the book data.
    #
    Book.all.each { |book| BooksIndex.add book }

That's already a nice setup. Whenever Rails starts up, this will add all books to the index.

From anywhere (if you have multiple, call `Picky::Indexes.index` to index all). 

Ok, this sets up the index and the indexing. What about the model?

In the model, here `app/models/book.rb` add this:
  
    # Two callbacks.
    #
    after_save    :picky_index
    after_destroy :picky_index
      
    # Updates the Picky index.
    #
    def picky_index
      if destroyed?
        BooksIndex.remove id
      else        
        BooksIndex.replace self
      end
    end

I actually recommend to use after_commit since it that would be perfectly correct, but it did not work at the time of writing.

Now, in the controller, you need to return some results to the user.

    # GET /books/search
    #
    def search
      results = BookSearch.search query, params[:ids] || 20, params[:offset] || 0
    
      # Render nicely as a partial.
      #
      results = results.to_hash
      results.extend Picky::Convenience
      results.populate_with Book do |book|
        render_to_string :partial => "book", :object => book
      end
    
      respond_to do |format|
        format.html do
          render :text => "Book result ids: #{results.ids.to_s}"
        end
        format.json do
          render :text => results.to_json
        end
      end
    end

The first line executes the search using query params. You can try this using `curl`:

    curl http://127.0.0.1:4567/books/search?query=test
    
The next few lines use the results as a hash, and populate the results with data loaded from the database, rendering a book partial.

Then, we respond to html with a simple web page, or respond to json with the results.

As you can see, you can do whatever you want with the results. You could use this in an API, or send simple text to the user, or whatever you want.

TODO Using the Picky client JavaScript. 

#### External Picky server

TODO

#### Advanced Ideas

TODO Reloading indexes live

TODO Prepending the current user to filter

    # Prepends the current user filter to
    # the current query.
    #
    query = "user:#{current_user.id} #{params[:query]}"

### Sinatra

TODO

TODO Also mention Padrino.

### DRb

TODO

### Ruby Script

TODO