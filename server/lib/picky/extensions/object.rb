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
    puts text
  end
  
end