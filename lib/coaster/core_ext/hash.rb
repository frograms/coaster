class Hash
  def deep_key_count(**options)
    keys.size + values.sum do |v|
      case v
      when Hash
        v.deep_key_count(**options)
      when Array
        if options[:array_is_element]
          0
        else
          v.deep_key_count(**options)
        end
      else
        0
      end
    end
  end
end
