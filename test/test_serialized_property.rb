require 'test_helper'
require 'minitest/autorun'

module Coaster
  class TestSerializedProperty < Minitest::Test
    def setup
    end

    def teardown
    end

    def test_serialized
      user = User.create(name: 'abc')
      user.init_appendix
      assert_equal 0, user.appendix['test_key1']
      assert_equal 0, user.appendix['test_key2']
    end
  end
end