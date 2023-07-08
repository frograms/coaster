require 'test_helper'
require 'minitest/autorun'
require 'coaster/git'

module Coaster
  module Git
    class TestOptions < Minitest::Test
      def test_options_to_s
        # assert_equal '-a b -c d  ', Options.new(nil, '-a' => 'b', '-c' => 'd').to_s
        assert_equal '--no-commit ', Options.new(nil, '--no-commit').to_s
        assert_equal '-c a=b', Options.new(nil, '-c' => {'a' => 'b'}).to_s
        assert_equal '-c a=b -c c=d', Options.new(nil, '-c' => {'a' => 'b', 'c' => 'd'}).to_s
        assert_equal '-c a=b -c c=d', Options.new(nil, '-c' => Set[{'a' => 'b'}, {'c' => 'd'}]).to_s
        assert_equal '--config=a=b,c=d', Options.new(nil, '--config' => [Set['a', 'b'], Set['c', 'd']]).to_s
        assert_equal '--config=a=b --config=c=d', Options.new(nil, '--config' => Set[{'a' => 'b'}, {'c' => 'd'}]).to_s
        assert_equal '-c a=b  -- aaa bbb', Options.new(nil, '-c' => {'a' => 'b'}, '--' => ['aaa', 'bbb']).to_s
      end

      def test_options_to_h
        opts = Options.new('git', '-c' => {'b' => 1}, '--config-env' => 'd=1')
        assert_equal({"--config-env"=>{"b"=>"1", "d"=>"1"}}, opts.to_h)
        assert_equal('--config-env=b=1 --config-env=d=1 ', opts.to_s)
        opts = Options.new('merge', '--no-commit')
        assert_equal({"--no-commit" => ''}, opts.to_h)
        assert_equal('--no-commit ', opts.to_s)
        opts = Options.new('git', {'-c' => {'a' => 'b'}, '--' => ['aaa', 'bbb']})
        assert_equal('-c a=b  -- aaa bbb', opts.to_s)
        assert_equal({"--config-env" => {"a" => "b"}, '--' => ['aaa', 'bbb']}, opts.to_h)
      end
    end
  end
end
