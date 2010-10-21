module Kernel
  
  
  def timed_exclaim text
    exclaim "#{Time.now.strftime("%H:%M:%S")}: #{text}"
  end
  
  def exclaim text
    puts text
  end
  
end