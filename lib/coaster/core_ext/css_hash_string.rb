module Coaster
  module CssHashString
    module HashToStyle
      def to_css_style(**defaults)
        to_css_hash(**defaults).map do |k, v|
          k = k.gsub(/_/, '-')
          v.present? ? "#{k}:#{v}" : nil
        end.compact.join(';')
      end

      def to_css_hash(**defaults)
        defaults = defaults.map do |k, v|
          k = k.to_s.gsub(/_/, '-')
          v.present? ? [k, v] : nil
        end.compact.to_h
        h = self.map do |k, v|
          k = k.to_s.gsub(/_/, '-')
          v.present? ? [k, v] : nil
        end.compact.to_h
        defaults.merge(h)
      end
    end
    ::Hash.send(:include, HashToStyle)
    ::ActiveSupport::HashWithIndifferentAccess.send(:include, HashToStyle)

    module StringToStyle
      def to_css_style(**defaults)
        return self unless defaults.present?
        to_css_hash(**defaults).to_css_style
      end

      def to_css_hash(**defaults)
        defaults.with_indifferent_access.merge(
          self.split(';').map do |pair|
            k, v = pair.split(':')
            [k.strip, v.strip]
          end.to_h
        )
      end
    end
    ::String.send(:include, StringToStyle)
  end
end
