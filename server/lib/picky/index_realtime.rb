module Picky

  #
  #
  class Index

    delegate :remove,  # aka delete.
             :add,     # aka insert.
             :replace, # aka insert or update.
             :clear_realtime,
             :build_realtime_mapping,
             :to => :categories

  end

end