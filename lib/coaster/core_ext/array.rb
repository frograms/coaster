class Array
  def toggle(value)
    if include?(value)
      delete(value)
      false
    else
      self << value
      true
    end
  end
end
