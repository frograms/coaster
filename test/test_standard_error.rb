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
      assert_equal e.to_hash['wat'], 'cha'
      assert_equal e.to_hash['type'], 'Coaster::TestStandardError::ExampleError'
      assert_equal e.to_hash['status'], 20
      assert_equal e.to_hash['http_status'], 500
      assert_equal e.to_hash['message'], 'Test sample error'
      assert_equal e.to_hash['cause']['frog'], 'rams'
      assert_equal e.to_hash['cause']['type'], 'Coaster::TestStandardError::SampleError'
      assert_equal e.to_hash['cause']['status'], 10
      assert_equal e.to_hash['cause']['http_status'], 500
      assert_equal e.to_hash['cause']['message'], 'Test sample error'
    end

    def test_cause_attributes
      begin
        raise SampleError, {frog: 'rams'}
      rescue => e
        raise ExampleError, {wat: 'cha'}
      end
    rescue => e
      assert_equal e.cause.attr['frog'], 'rams'
      assert_equal e.attr['frog'], 'rams'
      assert_equal e.attr['wat'], 'cha'
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
        assert_equal e.root_cause.message, 'a'
      end
    end

    def test_raven_notes
      raise SampleError, m: 'foofoo', something: 'other'
    rescue => e
      assert_equal e.notes(the_other: 'something')[:extra][:something], 'other'
      assert_equal e.notes(the_other: 'something')[:extra][:the_other], 'something'
    end

    def test_to_hash
      aa # raise NameError
    rescue => e
      assert_equal e.to_hash['type'], 'NameError'
      assert_equal e.to_hash['status'], 999999
      assert_equal e.to_hash['http_status'], 500
      assert e.to_hash['message'] =~ /undefined local variable or method `aa'/
    end

    def test_descriptions
      raise SampleError
    rescue => e
      e.descriptions.merge!(a: 1)
      assert_equal e.descriptions['a'], 1
    end

    class SampleErrorSub < SampleError; end
    class SampleErrorSubSub < SampleErrorSub; end
    SampleError.after_logging(:blah) { @blah = 101 }
    def test_before_logging
      e = SampleErrorSubSub.new(m: 'foo')
      assert !e.after_logging_blocks[:blah].nil?
      e.logging
      assert_equal e.instance_variable_get(:@blah), 101
    end
  end
end
