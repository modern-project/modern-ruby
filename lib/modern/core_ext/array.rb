class Array
  def subsequences
    (0..self.length).map do |n|
      self[0, n]
    end
  end
end
