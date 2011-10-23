module Picky

  #
  #
  class Index

    # TODO Rake troubles?
    #
    delegate :remove,
             :add,
             :replace,
             :to => :categories

  end

end