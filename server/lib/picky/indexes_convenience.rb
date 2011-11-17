module Picky

  class Indexes

    each_delegate :each_bundle,
                  :each_category,
                  :to => :indexes

  end

end