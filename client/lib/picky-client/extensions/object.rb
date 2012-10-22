class Object # :nodoc:all

  # Puts a text that informs the user of a missing gem.
  #
  unless instance_methods.include? :warn_gem_missing
    def warn_gem_missing gem_name, message
      warn "#{gem_name} gem missing!\nTo use #{message}, you need to:\n  1. Add the following line to Gemfile:\n     gem '#{gem_name}'\n  2. Then, run:\n     bundle update\n"
    end
  end

end