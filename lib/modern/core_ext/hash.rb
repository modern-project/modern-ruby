# frozen_string_literal: true

class Hash
  def deep_compact!
    compact!

    each_value do |v|
      if v.is_a?(Hash) || v.respond_to?(:values)
        v.deep_compact!
      elsif v.is_a?(Array) || v.respond_to?(:each)
        v.deep_compact!
      end
    end

    self
  end
end
