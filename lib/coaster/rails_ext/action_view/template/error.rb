# frozen_string_literal: true

module ActionView
  class Template
    class Error < ActionViewError
      # @return [Integer]
      def http_status
        cause.respond_to?(:http_status) ? cause.http_status : super
      end
    end
  end
end
