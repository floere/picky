module Picky

  #
  #
  class Index

    forward :each_bundle, :each_category, :to => :categories

  end

end