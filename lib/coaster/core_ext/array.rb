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
      when Hash
        v.deep_key_count(**options)
      when Array
        if options[:array_is_element]
          1
        else
          v.deep_key_count(**options)
        end
      else
        1
      end
    end
  end
end
