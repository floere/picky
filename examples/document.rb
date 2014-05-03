# Copy this into a Ruby file "document_search.rb", then:
#   ruby document_search.rb

require 'picky'

# Define an index.
#
data = Picky::Index.new :people do
           # Only keep alpha/blank characters.
  indexing removes_characters: /[^\p{Alpha}\p{Blank}]/i

                  # Only index full words.
  category :text, partial: Picky::Partial::None.new
end

# Define a data input class. Any object that responds to
# :id, :age, :name can be added to the index.
#
Document = Struct.new :id, :text

# Add some data objects to the index.
# IDs can be any unique string or integer.
#
File.open 'story.txt' do |story|
  data.add Document.new(1, story.read)
end

# Create a search interface object.
#
people = Picky::Search.new data

# Do two searches and remember the results.
#
found           = people.search 'nevermore'
only_full_words = people.search 'nevermor'
not_found       = people.search 'peter'

# Show the results.
#
p found.ids # => [1]
p only_full_words.ids # => []
p not_found.ids # => []