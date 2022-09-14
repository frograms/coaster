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
      a = {'a'=>[1], 'b'=>{'aa'=>1, 'bb'=>[2, 1]}}
      res = Util.flatten_hashify(a)
      assert_equal({"a"=>[1], "b.aa"=>1, "b.bb"=>[2, 1]}, res)
      b = Util.roughen_hashify(res)
      assert_equal(a, b)
      res = Util.flatten_hashify(a, array_start: 1)
      assert_equal({"a.1"=>1, "b.aa"=>1, "b.bb.1"=>2, "b.bb.2"=>1}, res)
      b = Util.roughen_hashify(res, array_start: 1)
      assert_equal(a, b)
      res = Util.flatten_hashify(a, array_start: 0)
      assert_equal({"a.0"=>1, "b.aa"=>1, "b.bb.0"=>2, "b.bb.1"=>1}, res)
      b = Util.roughen_hashify(res)
      assert_equal(a, b)
      res = Util.flatten_hashify([{a: 1}, 22, [33, 44], {b: {c: [33, {d: 4}]}}])
      assert_equal({""=>[{:a=>1}, 22, [33, 44], {:b=>{:c=>[33, {:d=>4}]}}]}, res) # no meaning result
      res = Util.flatten_hashify([{a: 1}, 22, [33, 44], {b: {c: [33, {d: 4}]}}], array_start: 1)
      assert_equal({"1.a"=>1, "2"=>22, "3.1"=>33, "3.2"=>44, "4.b.c.1"=>33, "4.b.c.2.d"=>4}, res)
    end

    def test_flatten_hashify_delimiter
      a = [{'a'=>1}, 22, [33, 44], {'b'=>{'c'=>[33, {'d'=>4}]}}]
      res = Util.flatten_hashify(a, array_start: 1, delimiter: '/')
      assert_equal({"1/a"=>1, "2"=>22, "3/1"=>33, "3/2"=>44, "4/b/c/1"=>33, "4/b/c/2/d"=>4}, res)
      b = Util.roughen_hashify(res, array_start: 1, delimiter: '/')
      assert_equal(a, b)
    end
  end
end
