# The Picky module that can be included.
#
# Note: This module might be reopened here.
#
module Picky
  
  # This must be the only place where this method is defined.
  # If there are others, then included must call the old,
  # aliased method too.
  #
  def self.included into
    into.extend Model::Indexing
    into.extend Model::Searching
  end
  
end