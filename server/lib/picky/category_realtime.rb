module Picky

  class Category

    class Picky::IdNotGivenException < StandardError; end

    # Adds and indexes this category of the
    # given object.
    #
    # @param object [Object] The thing to index.
    # @param method [Symbol] The method name to use on the id array.
    # @param force_update [Boolean] Whether to force update.
    #
    def add object, method: :unshift, force_update: false
      data = if from.respond_to? :call
        from.call(object)
      else
        object.send(from)
      end
      add_text object.send(id), data, method: method, force_update: force_update
    end
    
    # Removes an indexed object with the
    # given id.
    #
    # @param id [Object] The id of the object.
    #
    def remove id
      id = id.send key_format if key_format?
      exact.remove id
      partial.remove id
    end

    # Replaces an object. Will first check if each category of the object is in
    # the index it would insert, and if it is, will not insert.
    # Otherwise will delete and add.
    #
    # @param object [Object] The object to replace.
    # @param method [Symbol] The method name to use on the id array.
    #
    def replace object, method: :unshift
      remove object.send id
      add object, method: method
    end

    # Always removes the object's id, and then
    # adds the object again.
    #
    # Note: This puts a bit of a strain on Ruby's
    # memory management.
    #
    # @param object [Object] The object to replace.
    # @param method [Symbol] The method name to use on the id array.
    #
    def replace! object, method: :unshift
      remove object.send id
      add object, method: method
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
      add thing, method: __method__
    end

    # Add at the beginning.
    #
    def unshift thing
      add thing, method: __method__
    end

    # For the given id, adds the list of
    # strings to the index for the given id.
    #
    def add_text id, text_or_tokens, method: :unshift, force_update: false
      # text_or_tokens = text_or_tokens.to_sym if @symbol_keys # SYMBOLS.
      tokens = nil
      if tokenizer
        tokens, _ = tokenizer.tokenize text_or_tokens
      else
        tokens = text_or_tokens
      end

      format = key_format?
      static = static?
      tokens.each do |text|
        add_tokenized_token id, text, method: method, format: format, static: static, force_update: force_update
      end
    rescue NoMethodError => e
      show_informative_add_text_error_message_for e
    end

    def show_informative_add_text_error_message_for e
      if e.name == :each
        raise %Q{#{e.message}. You probably set tokenize: false on category "#{name}". It will need an Enumerator of previously tokenized tokens.}
      else
        raise e
      end
    end

    #
    #
    def add_tokenized_token id, text, method: :unshift, format: true, static: false, force_update: false
      return unless text

      id = id.send key_format if format
      text = text.to_sym if @symbol_keys # SYMBOLS.
      id.freeze

      exact.add id, text, method: method, static: static, force_update: force_update
      partial.add_partialized id, text, method: method, static: static, force_update: force_update
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
      exact.build_realtime @symbol_keys
      partial.build_realtime @symbol_keys
    end

  end

end
