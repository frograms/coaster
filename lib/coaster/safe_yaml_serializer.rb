# frozen_string_literal: true

module Coaster
  # +ActiveRecord::AttributeMethods::Serialization#serialize+ 적용시 YAML
  # 시리얼라이저로 지정한다. 다음과 같은 특징이 있다.
  #   * 안전한 YAML(+Psych.safe_load+ 가능한 YAML)로 시리얼라이즈한다.
  #   * +Hash+ 만 지원한다.
  #   * YAML 데이터가 nil 인 경우 +load+ 하면 빈 해시를 반환한다.
  #   * +load+ 는 +ActiveSupport::HashWithIndifferentAccess+ 를 반환한다.
  # ==== 주의
  #   * 해시 값에 지정된 객체는 기본 타입(String으로 변환된다
  #
  # ==== Example
  #   class User < ApplicationRecord
  #     serialize :data, SafeYamlSerializer
  #   end
  class SafeYamlSerializer
    class << self
      def dump(obj)
        return if obj.nil?
        YAML.dump(JSON.load(obj.to_json))
      end

      def _load_hash(yaml)
        return {} if yaml.nil?
        return yaml unless yaml.is_a?(String) && yaml.start_with?("---")

        if Rails.env.production?
          YAML.load(yaml)
        else
          begin
            YAML.safe_load(yaml, [], [], true) || {}
          rescue Psych::DisallowedClass => e
            # Rails.logger.warn e.inspect
            # Rails.logger.warn e.backtrace.join("\n")
            YAML.load(yaml) || {}
          end
        end
      end

      # @return [HashWithIndifferentAccess]
      def load(yaml)
        (_load_hash(yaml) || {}).with_indifferent_access
      end
    end
  end
end
