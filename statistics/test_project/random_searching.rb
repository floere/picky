PICKY_ENVIRONMENT = 'development'
require File.expand_path '../book',    __FILE__

size = 540
offsets = [0, 0, 0, 0, 0, 0, 0, 0, 20, 20, 20, 20, 40, 40, 60, 100, 120]

loop do
  # sleep rand*0.1
  book, _ = Book.find [rand(size)+1]
  title = book.instance_variable_get(:@title)
  title.squeeze! " "
  words = title.gsub(/[^\w\s\d\-]/, '').split(/[\-\s]/)
  query = []
  (rand(3) + 1).times do
    word = words[rand(words.length)]
    cut = word[0..word.length-rand(3)]
    word = cut unless cut.empty?
    query << word
  end
  puts query.join "* "
  
  offset = offsets[rand(offsets.size)]
  query = query.join "*%20"
  `curl -s 'localhost:8080/search/full?offset=#{offset}&query=#{query}'`
end