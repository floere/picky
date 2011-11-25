module Picky

  #
  #
  class Index

    # TODO Rake troubles?
    #
    delegate :remove,
             :add,
             :replace,
             :clear_realtime,
             :build_realtime_mapping,
             :to => :categories

  end

end