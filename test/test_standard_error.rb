require 'test_helper'
require 'minitest/autorun'
require 'coaster/core_ext/standard_error/raven'

module Coaster
  class TestStandardError < Minitest::Test
    class SampleError < StandardError
      def self.status; 10 end
    end

    class ExampleError < StandardError
      def self.status; 20 end
    end

    class UntitledError < StandardError; end

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
	@fingerprint: []
	@tags: {}
	@level: \"error\"
	@attributes: {\"wat\"=>\"cha\"}
	@tkey: nil
	@raven: {}
	CAUSE: [Coaster::TestStandardError::SampleError] status:10
		MESSAGE: Coaster::TestStandardError::SampleError
		@fingerprint: []
		@tags: {}
		@level: \"error\"
		@attributes: {\"frog\"=>\"rams\"}
		@tkey: nil
		@raven: {}
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

    def test_title_missing
      raise UntitledError, 'untitled'
    rescue => e
      assert_equal e.title, nil
    end

    def root_cause_sample1
      raise StandardError, 'a'
    end

    def root_cause_sample2
      root_cause_sample1
    rescue
      raise NoMethodError, 'b'
    end

    def root_cause_sample3
      root_cause_sample2
    rescue
      raise ArgumentError, 'c'
    end

    def test_root_cause
      begin
        root_cause_sample3
      rescue => e
        assert_equal e.root_cause.message, 'a'
      end
    end

    def test_raven_notes
      raise SampleError, m: 'foofoo', something: 'other'
    rescue => e
      assert_equal e.notes(the_other: 'something'), {extra: {something: 'other', the_other: 'something'}, fingerprint: [], tags: {}, level: 'error'}.with_indifferent_access
    end
  end
end
