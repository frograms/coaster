module Coaster
  module Util
    FLATTEN_HASH_DELIMITER = '.'.freeze

    class << self
      def flatten_hashify(object, delimiter: FLATTEN_HASH_DELIMITER, breadcrumbs: [], include_array: nil)
        case object
        when Hash
          object.each_with_object({}) do |(key, value), memo|
            memo.merge!(flatten_hashify(value, delimiter: delimiter, breadcrumbs: breadcrumbs + [key], include_array: include_array))
          end
        when Array
          if include_array
            object.each.with_index(1).with_object({}) do |(element, ix), memo|
              memo.merge!(flatten_hashify(element, delimiter: delimiter, breadcrumbs: breadcrumbs + [ix], include_array: include_array))
            end
          else
            {breadcrumbs.join(delimiter) => object}
          end
        else
          {breadcrumbs.join(delimiter) => object}
        end
      end
    end
  end
end
