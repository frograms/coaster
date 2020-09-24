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
      assert_equal 'cha', e.to_hash['wat']
      assert_equal 'Coaster::TestStandardError::ExampleError', e.to_hash['type']
      assert_equal 20, e.to_hash['status']
      assert_equal 500, e.to_hash['http_status']
      assert_equal 'Test sample error', e.to_hash['message']
      assert_equal 'rams', e.to_hash['cause']['frog']
      assert_equal 'Coaster::TestStandardError::SampleError', e.to_hash['cause']['type']
      assert_equal 10, e.to_hash['cause']['status']
      assert_equal 500, e.to_hash['cause']['http_status']
      assert_equal 'Test sample error', e.to_hash['cause']['message']
    end

    def test_cause_attributes
      begin
        raise SampleError, {frog: 'rams'}
      rescue => e
        raise ExampleError, {wat: 'cha'}
      end
    rescue => e
      assert_equal 'rams', e.cause.attr['frog']
      assert_equal 'rams', e.attr['frog']
      assert_equal 'cha', e.attr['wat']
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
	MESSAGE: Test sample error
	@fingerprint: []
	@tags: {}
	@level: \"error\"
	@attributes: {\"frog\"=>\"rams\", \"wat\"=>\"cha\"}
	@tkey: nil
	@raven: {}
	CAUSE: [Coaster::TestStandardError::SampleError] status:10
		MESSAGE: Test sample error
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
      assert_equal 'Test this translation', e._translate
    end

    def test_title
      raise SampleError, 'foobar'
    rescue => e
      assert_equal 'Test this title', e.title
    end

    def test_title_missing
      raise UntitledError, 'untitled'
    rescue => e
      assert_nil e.title
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
        assert_equal 'a', e.root_cause.message
      end
    end

    def test_raven_notes
      raise SampleError, m: 'foofoo', something: 'other'
    rescue => e
      assert_equal 'other', e.notes(the_other: 'something')[:extra][:something]
      assert_equal 'something', e.notes(the_other: 'something')[:extra][:the_other]
    end

    def test_to_hash
      aa # raise NameError
    rescue => e
      assert_equal 'NameError', e.to_hash['type']
      assert_equal 999999, e.to_hash['status']
      assert_equal 500, e.to_hash['http_status']
      assert_match /undefined local variable or method `aa'/, e.to_hash['message']
    end

    def test_descriptions
      raise SampleError
    rescue => e
      e.descriptions.merge!(a: 1)
      assert_equal 1, e.descriptions['a']
    end

    class SampleErrorSub < SampleError; end
    class SampleErrorSubSub < SampleErrorSub
      def it_might_happen?; true end
    end
    SampleError.after_logging(:blah) do 
      self.attributes[:abc] = 100
      @blah = 101
    end
    def test_before_logging
      e = SampleErrorSubSub.new(m: 'foo')
      assert !e.after_logging_blocks[:blah].nil?
      e.logging
      assert_equal 100, e.attributes[:abc]
      assert_equal 101, e.instance_variable_get(:@blah)
    end
    class SampleErrorMightHappen < SampleErrorSub
      def it_might_happen?; true end
    end
    def test_might_happen
      e = SampleErrorMightHappen.new('fbar')
      assert !e.report?
    end
  end
end
