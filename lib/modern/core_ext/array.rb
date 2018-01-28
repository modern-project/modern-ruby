# frozen_string_literal: true

class Array
  def subsequences
    (0..length).map do |n|
      self[0, n]
    end
  end
end
