# frozen_string_literal: true

require "minitest/autorun"
require "test_helper"
require "action_view"
require "coaster/rails_ext/action_view/template/error"

module Coaster
  class BadRequest < StandardError
    def self.http_status = 400
  end

  class TestActionView < Minitest::Test
    def test_http_status
      begin
        raise BadRequest
      rescue BadRequest => e
        template = ActionView::Template.new("Hello, World!", "test", ActionView::Template::Handlers::Raw, locals: [])
        err = ActionView::Template::Error.new(template)

        assert_equal err.cause, e
        assert_equal err.http_status, e.http_status
        assert_equal err.http_status, 400
      end
    end
  end
end
