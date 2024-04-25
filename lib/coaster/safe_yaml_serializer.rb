# frozen_string_literal: true

module Coaster
  class SafeYamlSerializer
    class << self
      def dump(obj)
        return if obj.nil?
        YAML.dump(JSON.load(obj.to_json))
      end

      def _load_hash(yaml)
        return {} if yaml.nil?
        return yaml unless yaml.is_a?(String) && yaml.start_with?("---")

        begin
          YAML.safe_load(yaml, permitted_classes: [Date, Time], aliases: true) || {}
        rescue Psych::DisallowedClass => e
          if YAML.respond_to?(:unsafe_load)
            YAML.unsafe_load(yaml) || {}
          else
            YAML.load(yaml) || {}
          end
        end
      end

      # @return [HashWithIndifferentAccess]
      def load(yaml)
        obj = _load_hash(yaml)
        obj = obj.with_indifferent_access if obj.is_a?(Hash)
        obj
      end
    end
  end
end
