require 'test_helper'
require 'minitest/autorun'
require 'coaster/util'

module Coaster
  class TestUtil < Minitest::Test
    def setup
    end

    def teardown
    end

    def test_flatten_hashify
      res = Util.flatten_hashify({a: [1], b: {aa: 1, bb: [2, 1]}})
      assert_equal({"a"=>[1], "b.aa"=>1, "b.bb"=>[2, 1]}, res)
      res = Util.flatten_hashify({a: [1], b: {aa: 1, bb: [2, 1]}}, include_array: true)
      assert_equal({"a.1"=>1, "b.aa"=>1, "b.bb.1"=>2, "b.bb.2"=>1}, res)
      res = Util.flatten_hashify([{a: 1}, 22, [33, 44], {b: {c: [33, {d: 4}]}}])
      assert_equal({""=>[{:a=>1}, 22, [33, 44], {:b=>{:c=>[33, {:d=>4}]}}]}, res) # no meaning result
      res = Util.flatten_hashify([{a: 1}, 22, [33, 44], {b: {c: [33, {d: 4}]}}], include_array: true)
      assert_equal({"1.a"=>1, "2"=>22, "3.1"=>33, "3.2"=>44, "4.b.c.1"=>33, "4.b.c.2.d"=>4}, res)
    end

    def test_flatten_hashify_delimiter
      res = Util.flatten_hashify([{a: 1}, 22, [33, 44], {b: {c: [33, {d: 4}]}}], include_array: true, delimiter: '/')
      assert_equal({"1/a"=>1, "2"=>22, "3/1"=>33, "3/2"=>44, "4/b/c/1"=>33, "4/b/c/2/d"=>4}, res)
    end
  end
end
