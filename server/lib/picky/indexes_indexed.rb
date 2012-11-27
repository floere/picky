module Picky

  # Registers the indexes held at runtime, for queries.
  #
  class Indexes

    instance_forward :load, :analyze
    each_forward :load, :to => :indexes

  end

end