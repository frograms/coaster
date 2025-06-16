require 'test_helper'
require 'minitest/autorun'
require 'coaster/core_ext/memory_size'

module Coaster
  class TestMemorySize < Minitest::Test
    class Some
      attr_accessor :aa, :bb, :cc
    end

    def setup
    end

    def teardown
    end

    def test_memory_size
      h = {"aa" => 1, "bb" => [2, 3], "cc" => {"dd" => 4}}
      # assert_equal 10, {"aa" => 1, "bb" => [2, 3], "cc" => {"dd" => 4}}.memory_size
      assert_equal({nil => {nil => 160}, "aa" => 40, "bb" => 80, "cc" => 240}, h.memory_size(depth: 0))
      assert_equal 520, h.memory_size_total
      some = Some.new
      some.aa = h
      some.bb = [1, 2, 3]
      some.cc = {"dd" => 4, "ee" => [5, 6]}
      depth_0 = some.memory_size(depth: 0)
      depth_1 = some.memory_size(depth: 1)
      assert_equal({nil => 40, "@aa": 520, "@bb": 40, "@cc": 280}, depth_0)
      assert_equal({nil => 40, 
        "@aa": {nil => {nil => 160}, "aa" => 40, "bb" => 80, "cc" => 240}, 
        "@bb": {nil => {nil => 40}, 0 => 0, 1 => 0, 2 => 0}, 
        "@cc": {nil => {nil => 160}, "dd" => 40, "ee" => 80}}, depth_1)
      assert_equal 880, some.memory_size_total
    end
  end
end
