require 'test_helper'
require 'minitest/autorun'
require 'coaster/git'

module Coaster
  class TestGit < Minitest::Test
    include Coaster::Git

    def test_option_parse
      assert_equal '-a b -c d ', options_h_to_s('-a' => 'b', '-c' => 'd')
      assert_equal '--no-commit', options_to_s('--no-commit')
      assert_equal '-c a=b ', options_to_s('-c' => {'a' => 'b'})
      assert_equal '-c a=b,c=d ', options_to_s('-c' => {'a' => 'b', 'c' => 'd'})
      assert_equal '-c a=b -c c=d ', options_to_s('-c' => Set[{'a' => 'b'}, {'c' => 'd'}])
      assert_equal '--config=a=b,c=d ', options_to_s('--config' => [{'a' => 'b'}, {'c' => 'd'}])
      assert_equal '--config=a=b --config=c=d ', options_to_s('--config' => Set[{'a' => 'b'}, {'c' => 'd'}])
      assert_equal '-c a=b  -- aaa bbb', options_to_s('-c' => {'a' => 'b'}, '--' => ['aaa', 'bbb'])
    end
  end
end
