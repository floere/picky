class Object
  
  # Puts a text in the form:
  #   12:34:56: text here
  #
  def timed_exclaim text
    exclaim "#{Time.now.strftime("%H:%M:%S")}: #{text}"
  end

  # Just puts the given text.
  #
  def exclaim text
    Picky.logger.info text
    Picky.logger.flush
  end

  # Puts a text that informs the user of a missing gem.
  #
  def warn_gem_missing gem_name, message
    warn "#{gem_name} gem missing!\nTo use #{message}, you need to:\n  1. Add the following line to Gemfile:\n     gem '#{gem_name}'\n     or\n     require '#{gem_name}'\n     for example at the top of your app.rb file.\n  2. Then, run:\n     bundle update\n"
  end

  # Indents each line by <tt>amount=2</tt> spaces.
  #
  def indented_to_s amount = 2
    ary = self.respond_to?(:join) ? self : self.to_s.split("\n")
    ary.map { |s| "#{" "*amount}#{s}"}.join("\n")
  end

end