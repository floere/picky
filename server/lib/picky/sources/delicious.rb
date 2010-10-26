module Sources
  
  class Delicious < Base
    
    def initialize username, password
      check_gem
      @username = username
      @password = password
    end
    def check_gem
      require 'www/delicious'
    rescue LoadError
      puts "Delicious gem missing!\nTo use the delicious source, you need to:\n  1. Add the following line to Gemfile:\n     gem 'www-delicious'\n  2. Then, run:\n     bundle update\n"
      exit(1)
    end
    
    # Harvests the data to index.
    #
    def harvest _, field
      get_data do |uid, data|
        indexed_id = uid
        text = data[field.name]
        next unless text
        text.force_encoding 'utf-8' # TODO Still needed?
        yield indexed_id, text
      end
    end
    
    #
    #
    def get_data
      @generated_id ||= 0
      @posts ||= WWW::Delicious.new(@username, @password).posts_recent(:count => 100)
      @posts.each do |post|
        data = {
          :title => post.title,
          :tags  => post.tags.join(' '),
          :url   => post.url.to_s
        }
        @generated_id += 1
        yield @generated_id, data
      end
    end
    
  end
  
end