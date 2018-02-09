# frozen_string_literal: true

class Array
  def subsequences
    (0..length).map do |n|
      self[0, n]
    end
  end

  def duplicates
    group_by(&:itself).map { |e| e[0] if e[1][1] }.compact
  end

  def deep_compact!
    each do |v|
      if v.is_a?(Hash) || v.respond_to?(:values)
        v.values.deep_compact!
      elsif v.is_a?(Array) || v.respond_to?(:each)
        v.deep_compact!
      end
    end
  end
end
