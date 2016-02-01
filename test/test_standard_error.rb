require 'test_helper'
require 'minitest/autorun'

module Coaster
  class TestStandardError < Minitest::Test
    class SampleError < StandardError
      def self.status; 10 end
    end

    class ExampleError < StandardError
      def self.status; 20 end
    end

    def setup
      I18n.backend = I18n::Backend::Simple.new
      I18n.load_path += [File.expand_path('../locales/en.yml', __FILE__)]
      I18n.enforce_available_locales = false
    end

    def test_message
      raise SampleError, {m: 'beer is proof'}
    rescue => e
      assert_equal 'beer is proof', e.message
    end

    def test_attributes
      raise SampleError, {blah: 'foo'}
    rescue => e
      assert_equal 'foo', e.attr[:blah]
    end

    def test_hash
      begin
        raise SampleError, {frog: 'rams'}
      rescue => e
        raise ExampleError, {wat: 'cha'}
      end
    rescue => e
      assert_equal({
        "wat"=>"cha",
        "type"=>"Coaster::TestStandardError::ExampleError",
        "status"=>20,
        "http_status"=>500,
        "message"=>"Coaster::TestStandardError::SampleError",
        "cause"=>{
          "frog"=>"rams",
          "type"=>"Coaster::TestStandardError::SampleError",
          "status"=>10,
          "http_status"=>500,
          "message"=>"Coaster::TestStandardError::SampleError"
        }
      }, e.to_hash)
    end

    def test_cause_attributes
      begin
        raise SampleError, {frog: 'rams'}
      rescue => e
        raise ExampleError, {wat: 'cha'}
      end
    rescue => e
      assert_equal({frog: 'rams', wat: 'cha'}.with_indifferent_access, e.attr)
    end

    def test_to_detail
      begin
        raise SampleError, {frog: 'rams'}
      rescue => e
        raise ExampleError, {wat: 'cha'}
      end
    rescue => e
      detail = <<-LOG
[Coaster::TestStandardError::ExampleError] status:20
	MESSAGE: Coaster::TestStandardError::SampleError
	@tags: []
	@level: \"error\"
	@attributes: {\"wat\"=>\"cha\"}
	@tkey: nil
	CAUSE: [Coaster::TestStandardError::SampleError] status:10
		MESSAGE: Coaster::TestStandardError::SampleError
		@tags: []
		@level: \"error\"
		@attributes: {\"frog\"=>\"rams\"}
		@tkey: nil
LOG
      assert_equal(detail, e.to_detail)
    end

    def test_translation
      raise SampleError, {tkey: '.test'}
    rescue => e
      assert_equal e._translate, 'Test this translation'
    end

    def test_title
      raise SampleError, 'foobar'
    rescue => e
      assert_equal e.title, 'Test this title'
    end
  end
end
