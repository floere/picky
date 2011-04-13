module Sources

  # Describes a Delicious (http://deli.cio.us) source.
  #
  # This source has a fixed set of categories:
  # * title
  # * tags
  # * url
  #
  # Examples:
  #  Sources::CSV.new('usrnam', 'paswrd')
  #
  class Delicious < Base

    def initialize username, password
      check_gem
      @username = username
      @password = password
    end
    def check_gem # :nodoc:
      require 'www/delicious'
    rescue LoadError
      warn_gem_missing 'www-delicious', 'the delicious source'
      exit 1
    end

    def to_s
      "#{self.class.name}(#{@username})"
    end

    # Harvests the data to index.
    #
    def harvest category
      get_data do |indexed_id, data|
        text = data[category.from]
        next unless text
        yield indexed_id, text
      end
    end

    #
    #
    def get_data # :nodoc:
      @generated_id ||= 0
      @posts ||= WWW::Delicious.new(@username, @password).posts_recent(count: 100)
      @posts.each do |post|
        data = {
          title: post.title,
          tags:  post.tags.join(' '),
          url:   post.url.to_s
        }
        @generated_id += 1
        yield @generated_id, data
      end
    end

  end

end