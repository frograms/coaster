require 'test_helper'
require 'minitest/autorun'

module Coaster
  class TestMonth < Minitest::Test
    def setup
      Time.zone = 'Asia/Seoul'
    end

    def test_month
      m = Month.parse('202001')
      assert_equal m.year, 2020
      assert_equal m.last_date, Date.parse('20200131')
      assert_equal m.end_of_month, Date.parse('20200131').end_of_day
      assert_equal m.to_time_range, Date.parse('20200101').beginning_of_day...Date.parse('20200201').beginning_of_day
      assert_equal m.to_s, '2020-01'
    end

    def test_timezone
      m = Month.parse('202001', timezone: 'Pacific/Midway')
      assert_equal m.timezone, ActiveSupport::TimeZone['Pacific/Midway']
      assert_equal m.beginning_of_month, Date.parse('20200101').in_time_zone('Pacific/Midway')
    end

    def test_next_specific_date
      d = Date.parse('20200101')
      assert_equal d.next_specific_date(1), Date.parse('20200201')
      assert_equal d.next_specific_date(2), Date.parse('20200102')
      assert_equal d.next_specific_date(31), Date.parse('20200131')
      d = Date.parse('20200131')
      assert_equal d.next_specific_date(31), Date.parse('20200229')
      d = Date.parse('20200130')
      assert_equal d.next_specific_date(31), Date.parse('20200131')
      d = Date.parse('20200129')
      assert_equal d.next_specific_date(29), Date.parse('20200229')
      d = Date.parse('20200210')
      assert_equal d.next_specific_date(29), Date.parse('20200229')
      assert_equal d.next_specific_date(30), Date.parse('20200229')
      assert_equal d.next_specific_date(31), Date.parse('20200229')
      d = Date.parse('20210210')
      assert_equal d.next_specific_date(9), Date.parse('20210309')
      assert_equal d.next_specific_date(10), Date.parse('20210310')
      assert_equal d.next_specific_date(29), Date.parse('20210228')
      assert_equal d.next_specific_date(30), Date.parse('20210228')
      assert_equal d.next_specific_date(31), Date.parse('20210228')
      d = Date.parse('20210228')
      assert_equal d.next_specific_date(31), Date.parse('20210331')
    end

    def test_prev_specific_date
      d = Date.parse('20200101')
      assert_equal d.prev_specific_date(1), Date.parse('20191201')
      assert_equal d.prev_specific_date(2), Date.parse('20191202')
      assert_equal d.prev_specific_date(31), Date.parse('20191231')
      d = Date.parse('20200331')
      assert_equal d.prev_specific_date(31), Date.parse('20200229')
      assert_equal d.prev_specific_date(30), Date.parse('20200330')
      d = Date.parse('20200330')
      assert_equal d.prev_specific_date(30), Date.parse('20200229')
      d = Date.parse('20200229')
      assert_equal d.prev_specific_date(29), Date.parse('20200129')
      assert_equal d.prev_specific_date(30), Date.parse('20200130')
      assert_equal d.prev_specific_date(31), Date.parse('20200131')
    end

    def test_range
      mn = Month.now
      range = (mn..mn)
      assert range.cover?(Month.from(Date.today))
    end

    def test_hash
      h = {Month.now => 1}
      assert_equal h[Month.now], 1
    end
  end
end
