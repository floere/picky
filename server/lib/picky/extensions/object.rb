class Object
  
  # Puts a text in the form:
  #   12:34:56: text here
  #
  def timed_exclaim text
    exclaim "#{Time.now.strftime("%H:%M:%S")}: #{text}"
  end

  # Just outputs the given text to the logger.
  #
  # Note: stubbed in spec_helper.rb
  #
  def exclaim text
    Picky.logger.info text
    Picky.logger.flush
  end

  # Puts a text that informs the user of a missing gem.
  #
  def warn_gem_missing gem_name, message
    Picky.logger.warn <<-WARNING
Warning: #{gem_name} gem missing!
To use #{message}, you need to:
  1. Add the following line to Gemfile:
     gem '#{gem_name}'
     or
     require '#{gem_name}'
     for example at the top of your app.rb file.
  2. Then, run:
     bundle update
WARNING
  end

  # Indents each line by <tt>amount=2</tt> spaces.
  #
  def indented_to_s amount = 2
    ary = self.respond_to?(:join) ? self : self.to_s.split("\n")
    ary.map { |s| "#{" "*amount}#{s}"}.join("\n")
  end

end