class CSVBook < Each
  module Accessibility
    def id
      self[0]
    end
    [:title, :author, :isbn, :year, :publisher, :subjects].each.with_index do |field, i|
      i = i+1
      define_method field do
        self[i]
      end
    end
  end
end
