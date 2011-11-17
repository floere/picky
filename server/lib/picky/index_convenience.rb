module Picky

  #
  #
  class Index

    delegate :each_bundle,
             :each_category,
             :to => :categories

  end

end