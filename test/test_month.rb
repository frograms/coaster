require 'test_helper'
require 'minitest/autorun'

module Coaster
  class TestMonth < Minitest::Test
    def test_month
      m = Month.parse('202001')
      assert_equal m.year, 2020
      assert_equal m.last_date, Date.parse('20200131')
      assert_equal m.end_of_month, Date.parse('20200131').end_of_day
      assert_equal m.to_time_range, Date.parse('20200101').beginning_of_day...Date.parse('20200201').beginning_of_day
    end
  end
end
