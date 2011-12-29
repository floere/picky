require File.expand_path '../../../server/lib/picky', __FILE__

# In this example, we have a search engine
# for people, and ads that should be shown
# when someone enters a specific location.
#
# To achieve this, we first search for the
# person itself, but then also search for the
# accompanying ad.
#
data = Picky::Index.new :people do
  category :name
  category :location
end

LocationPerson = Struct.new :id, :name, :location 
data.replace LocationPerson.new(1, 'Donald',  'Washington')
data.replace LocationPerson.new(2, 'Niklaus', 'Zurich')
data.replace LocationPerson.new(3, 'Frank',   'London')
data.replace LocationPerson.new(4, 'Peter',   'Paris')

ad_data = Picky::Index.new :ads do
  category :location
end

Ad = Struct.new :id, :tagline, :location
ad_data.replace Ad.new(1, 'Flower Shop London', 'London')
ad_data.replace Ad.new(2, 'Zurich Banking Coop', 'Zurich')

people = Picky::Search.new data

# The ad search throws away any word that cannot
# be found in the index using ignore_unassigned_tokens.
#
ads = Picky::Search.new ad_data do
  ignore_unassigned_tokens
end

# Case 1: Only person name used. 
#
query = 'donald'
fail __FILE__ unless people.search(query).ids == [1]
fail __FILE__ unless ads.search(query).ids == [] # No ads.

# Case 2: Name plus location used. 
#
query = 'frank london'
fail __FILE__ unless people.search(query).ids == [3]
fail __FILE__ unless ads.search(query).ids == [1] # Ad from London.

# Case 3: Only location used. 
#
query = 'zurich'
fail __FILE__ unless people.search(query).ids == [2] # Finds people from Zurich.
fail __FILE__ unless ads.search(query).ids == [2] # Ad from Zurich.

# Case 4: Wrong name & location used.
#
# Note: In this case you could break off
# after the person search if that returns 0 total results
# (results.total.zero? == true).
#
query = 'peter london'
fail __FILE__ unless people.search(query).ids == [] # Finds nobody.
# You could break off here if people.search(query).total.zero?
fail __FILE__ unless ads.search(query).ids == [1] # Still finds ad from London.
