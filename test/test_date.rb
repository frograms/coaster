require 'test_helper'
require 'minitest/autorun'

module Coaster
  class TestMonth < Minitest::Test
    def setup
      Time.zone = 'Asia/Seoul'
    end

    def test_date_time_range
      d = Date.parse('20200101')
      assert_equal d.to_time_range, Time.zone.parse('2020-01-01 00:00:00')...Time.zone.parse('2020-01-02 00:00:00')
      range = d.to_time_range('Pacific/Midway')
      assert_equal range, ActiveSupport::TimeZone['Pacific/Midway'].parse('2020-01-01 00:00:00')...ActiveSupport::TimeZone['Pacific/Midway'].parse('2020-01-02 00:00:00')
    end
  end
end
