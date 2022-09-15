module Coaster
  module Util
    FLATTEN_HASH_DELIMITER = '.'.freeze
    ARRAY_START = 0

    class << self
      # array_start가 0이면 array를 {'0'=>'blah', '1'=>'vlah'}
      # array_start가 1이면 array를 {'1'=>'blah', '2'=>'vlah'}
      # array_start가 nil이면 그대로 ['blah', 'vlah'] 로 처리
      def flatten_hashify(object, delimiter: FLATTEN_HASH_DELIMITER, breadcrumbs: [], array_start: nil)
        case object
        when Hash
          object.each_with_object({}) do |(key, value), memo|
            memo.merge!(flatten_hashify(value, delimiter: delimiter, breadcrumbs: breadcrumbs + [key], array_start: array_start))
          end
        when Array
          if array_start
            object.each.with_index(array_start).with_object({}) do |(element, ix), memo|
              memo.merge!(flatten_hashify(element, delimiter: delimiter, breadcrumbs: breadcrumbs + [ix], array_start: array_start))
            end
          else
            {breadcrumbs.join(delimiter) => object}
          end
        else
          {breadcrumbs.join(delimiter) => object}
        end
      end

      # 숫자로 된 키는 무조건 array로 처리함
      # array_start는 nil일 경우 기본값은 Util::ARRAY_START = 0
      def roughen_hashify(object, delimiter: FLATTEN_HASH_DELIMITER, array_start: nil)
        array_start ||= ARRAY_START

        step1 = object.each_with_object({}) do |(key, value), memo|
          sp_keys = key.split(delimiter)
          k = sp_keys.shift
          if sp_keys.present?
            memo[k] ||= {}
            memo[k][sp_keys.join(delimiter)] = value
          else
            memo[k] = value
          end
        end

        step2 = step1.each_with_object({}) do |(key, value), memo|
          case value
          when Hash
            memo[key] = roughen_hashify(value, delimiter: delimiter, array_start: array_start)
          else
            memo[key] = value
          end
        end

        array_keys = (array_start...(step2.keys.size+array_start)).to_a
        if array_keys == step2.keys.map(&:to_i).sort
          step3 = []
          array_keys.map(&:to_s).each do |k|
            step3 << step2[k]
          end
          step3
        else
          step2
        end
      end
    end
  end
end
