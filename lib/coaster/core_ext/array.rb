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

  def deep_key_count(**options)
    sum do |v|
      case v
      when Hash, Array
        v.deep_key_count
      else
        1
      end
    end
  end
end
