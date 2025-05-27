require 'test_helper'
require 'minitest/autorun'

module Coaster
  class TestDeepKeyCount < Minitest::Test
    def test_deep_key_count
      assert_equal 0, {}.deep_key_count
      assert_equal 1, {a: 1}.deep_key_count
      assert_equal 2, {a: {b: 1}}.deep_key_count
      assert_equal 3, {a: {b: 1, c: 2}}.deep_key_count
      assert_equal 6, {a: {b: 1, c: 2, d: [1, 2]}}.deep_key_count

      assert_equal 0, [].deep_key_count
      assert_equal 1, [1].deep_key_count
      assert_equal 2, [1, 2].deep_key_count
      assert_equal 2, [1, {b: 2}].deep_key_count
      assert_equal 3, [1, {b: 2}, 3].deep_key_count
      assert_equal 4, [1, {b: 2}, 3, {c: 4}].deep_key_count
      assert_equal 5, [1, {b: 2}, 3, [{c: 4}, 5]].deep_key_count
    end

    def test_deep_key_count_array_is_element
      assert_equal 1, {a: [1, 2]}.deep_key_count(array_is_element: true)
      assert_equal 1, {a: [1, {b: 2}]}.deep_key_count(array_is_element: true)

      assert_equal 2, [1, 2].deep_key_count(array_is_element: true)
      assert_equal 2, [1, {b: 2}].deep_key_count(array_is_element: true)
      assert_equal 3, [1, {b: 2, c: [1, 2]}].deep_key_count(array_is_element: true)

      assert_equal 3, [1, {b: 2}, 3].deep_key_count(array_is_element: true)
      assert_equal 3, [1, {b: 2}, [3, 4]].deep_key_count(array_is_element: true)
    end
  end
end
