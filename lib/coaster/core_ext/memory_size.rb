require 'objspace'

class Object
  def memory_size(depth: 2, object_ids: [])
    res = {nil => ObjectSpace.memsize_of(self)}
    instance_variables.each do |var|
      iv = instance_variable_get(var)
      if object_ids.include?(iv.object_id)
        res[var] = nil
      else
        object_ids << iv.object_id
        if depth > 0
          res[var] = iv.memory_size(depth: depth - 1, object_ids:)
        else
          res[var] = iv.memory_size_total(object_ids:)
        end
      end
    end
    res
  end

  def memory_size_total(object_ids: [])
    sum = 0
    memory_size(depth: 0, object_ids:).each do |k, v|
      case v
      when Hash, Array then sum += v._memory_size_total
      when nil then next
      else sum += v
      end
    end
    sum
  end
end

class Array
  def memory_size(depth: 2, object_ids: [])
    res = {nil => super}
    each_with_index do |item, x|
      if depth > 0
        res[x] = item.memory_size(depth: depth - 1, object_ids:)
      else
        res[x] = item.memory_size_total(object_ids:)
      end
    end
    res
  end

  def _memory_size_total
    sum = 0
    each do |item|
      case item
      when Hash, Array then sum += item._memory_size_total
      when nil then next
      else sum += item
      end
    end
    sum
  end
end

class Hash
  def memory_size(depth: 2, object_ids: [])
    res = {nil => super}
    each do |k, v|
      if depth > 0
        res[k] = [k.memory_size(depth: depth - 1, object_ids:), v.memory_size(depth: depth - 1, object_ids:)]
      else
        res[k] = k.memory_size_total(object_ids:) + v.memory_size_total(object_ids:)
      end
    end
    res
  end

  def _memory_size_total
    sum = 0
    each do |k, v|
      case v
      when Hash, Array then sum += v._memory_size_total
      when nil then next
      else sum += v
      end
    end
    sum
  end
end
