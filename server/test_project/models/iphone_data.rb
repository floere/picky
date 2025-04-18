class IphoneData < Each
  module Accessibility
    def id
      self[0]
    end
    [:mcc,
    :mnc,
    :lac,
    :ci,
    :timestamp,
    :latitude,
    :longitude,
    :horizontal_accuracy,
    :altitude,
    :vertical_accuracy,
    :speed,
    :course,
    :confidence].each.with_index do |field, i|
      define_method field do
        self[i]
      end
    end
  end
end