module Coaster
  module DeepKeyCount
    module HashCnt
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
    ::Hash.send(:include, HashCnt)
    ::ActiveSupport::HashWithIndifferentAccess.send(:include, HashCnt)

    module ArrayCnt
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
    ::Array.send(:include, ArrayCnt)
  end
end
