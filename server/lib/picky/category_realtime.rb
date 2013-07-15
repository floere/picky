module Picky

  class Category
    
    class Picky::IdNotGivenException < StandardError; end

    # Removes an indexed object with the
    # given id.
    #
    def remove id
      id = id.send key_format if key_format?
      exact.remove id
      partial.remove id
    end

    # Adds and indexes this category of the
    # given object.
    #
    # TODO Don't do this super-dynamically.
    #
    def add object, where = :unshift
      if from.respond_to? :call
        add_text object.id, from.call(object), where
      else
        add_text object.id, object.send(from), where
      end
    end

    # Removes the object's id, and then
    # adds it again.
    #
    def replace object, where = :unshift
      remove object.id
      add object, where
    end
    
    # Replaces just part of the indexed data.
    #
    # Note: Takes a hash as opposed to the add/replace method.
    #
    def replace_from hash #, id = (hash[:id] || hash['id'] || raise(IdNotGivenException.new)).send(key_format)
      return unless text = hash[from] || hash[from.to_s]
      
      raise IdNotGivenException.new unless id = hash[:id] || hash['id']
      id = id.send key_format if key_format?
      
      remove id
      add_text id, text
    end

    # Add at the end.
    #
    def << thing
      add thing, __method__
    end

    # Add at the beginning.
    #
    def unshift thing
      add thing, __method__
    end

    # For the given id, adds the list of
    # strings to the index for the given id.
    #
    def add_text id, text_or_tokens, where = :unshift
      # text = text.to_sym if @symbols # SYMBOLS.
      tokens = nil
      if tokenizer
        tokens, _ = tokenizer.tokenize text_or_tokens
      else
        tokens = text_or_tokens
      end
      
      format = self.key_format?
      tokens.each { |text| add_tokenized_token id, text, where, format }
    rescue NoMethodError
      # TODO Improve error message by pointing out what exactly goes wrong: thing xy does not have an #each method.
      raise %Q{You probably set tokenize: false on category "#{name}". It will need an Enumerator of previously tokenized tokens.}
    end

    #
    #
    def add_tokenized_token id, text, where = :unshift, format = true
      return unless text
      
      id = id.send key_format if format
      # text = text.to_sym if @symbols # SYMBOLS.

      exact.add id, text, where
      partial.add_partialized id, text, where
    rescue NoMethodError => e
      puts e.message
      raise %Q{The object id with text "#{text}" does not respond to method #{key_format}.}
    end

    # Clears the realtime mapping.
    #
    def clear_realtime
      exact.clear_realtime
      partial.clear_realtime
    end

    # Builds the realtime mapping.
    #
    def build_realtime_mapping
      exact.build_realtime
      partial.build_realtime
    end

  end

end
