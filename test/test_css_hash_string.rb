require 'test_helper'
require 'minitest/autorun'
require 'coaster/core_ext/css_hash_string'

module Coaster
  class TestCssHashString < Minitest::Test
    def setup
    end

    def teardown
    end

    def test_hash_to_style
      assert_equal "font-size:12px;color:red", {"font-size" => '12px', color: 'red'}.to_css_style
      assert_equal "font-size:12px;color:red", {font_size: '12px', color: 'red'}.to_css_style
      assert_equal "font-size:12px;color:red", {font_size: '12px', color: 'red'}.with_indifferent_access.to_css_style
    end

    def test_string_to_css_hash
      assert_equal({"font-size" => '12px', "color" => 'red'}, "font-size: 12px; color: red".to_css_hash)
      assert_equal({"font-size" => '12px', "color" => 'red'}, "font-size: 12px".to_css_hash(color: 'red'))
      assert_equal({"font-size" => '12px', "color" => 'blue'}, "font-size: 12px; color: blue".to_css_hash(color: 'red'))
    end
  end
end
