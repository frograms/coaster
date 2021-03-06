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

    def test_standard_messages
      e = StandardError.new('developer message')
      assert_equal "developer message", e.to_s
      assert_equal "developer message", e.message
      assert_nil e.description
      assert_nil e.desc
      assert_equal 'standard error translation', e._translate
      assert_equal 'standard error translation (developer message)', e.user_message
      assert_equal 'standard error title', e.title
      e = StandardError.new(m: 'developer message', desc: 'user message')
      assert_equal "user message (developer message)", e.to_s
      assert_equal "user message (developer message)", e.message
      assert_equal 'user message', e.description
      assert_equal 'user message', e.desc
      assert_equal 'user message', e._translate
      assert_equal 'user message', e.user_message
      assert_equal 'standard error title', e.title
    end

    def test_no_translation_class
      e = UntitledError.new('developer message')
      assert_equal "developer message", e.to_s
      assert_equal "developer message", e.message
      assert_nil e.description
      assert_nil e.desc
      assert_equal 'standard error translation', e._translate
      assert_equal 'standard error translation (developer message)', e.user_message
      assert_equal 'standard error title', e.title
      e = UntitledError.new(m: 'developer message', desc: 'user message')
      assert_equal "user message (developer message)", e.to_s
      assert_equal "user message (developer message)", e.message
      assert_equal 'user message', e.description
      assert_equal 'user message', e.desc
      assert_equal 'user message', e._translate
      assert_equal 'user message', e.user_message
      assert_equal 'standard error title', e.title
      e = UntitledError.new(tkey: 'no.translation')
      assert_equal "translation missing: en.no.translation (Coaster::TestStandardError::UntitledError)", e.to_s
      assert_equal "translation missing: en.no.translation (Coaster::TestStandardError::UntitledError)", e.message
      assert_nil e.description
      assert_nil e.desc
      assert_equal 'translation missing: en.no.translation', e._translate
      assert_equal "translation missing: en.no.translation", e.user_message
      assert_equal 'standard error title', e.title
    end

    def test_with_translation_class
      e = SampleError.new
      assert_equal "Coaster::TestStandardError::SampleError", e.to_s
      assert_equal "Coaster::TestStandardError::SampleError", e.message
      assert_nil e.description
      assert_nil e.desc
      assert_equal 'Test sample error', e._translate
      assert_equal 'Test sample error (Coaster::TestStandardError::SampleError)', e.user_message
      assert_equal 'Test this title',  e.title
      e = SampleError.new(beet: 'apple')
      assert_equal "Test sample error (Coaster::TestStandardError::SampleError)", e.to_s
      assert_equal "Test sample error (Coaster::TestStandardError::SampleError)", e.message
      assert_nil e.description
      assert_nil e.desc
      assert_equal 'Test sample error', e._translate
      assert_equal 'Test sample error (Coaster::TestStandardError::SampleError)', e.user_message
      assert_equal 'Test this title',  e.title
      e = SampleError.new('developer message')
      assert_equal "developer message", e.to_s
      assert_equal "developer message", e.message
      assert_nil e.description
      assert_nil e.desc
      assert_equal 'Test sample error', e._translate
      assert_equal 'Test sample error (developer message)', e.user_message
      assert_equal 'Test this title', e.title
      e = SampleError.new(desc: 'user message')
      assert_equal "user message (Coaster::TestStandardError::SampleError)", e.to_s
      assert_equal "user message (Coaster::TestStandardError::SampleError)", e.message
      assert_equal 'user message', e.description
      assert_equal 'user message', e.desc
      assert_equal 'user message', e._translate
      assert_equal 'user message', e.user_message
      assert_equal 'Test this title', e.title
      e = SampleError.new(m: 'developer message', desc: :translate)
      assert_equal "Test sample error (developer message)", e.to_s
      assert_equal "Test sample error (developer message)", e.message
      assert_equal "Test sample error", e.description
      assert_equal "Test sample error", e.desc
      assert_equal 'Test sample error', e._translate
      assert_equal 'Test sample error', e.user_message
      assert_equal 'Test this title', e.title
      e = SampleError.new(desc: :translate)
      assert_equal "Test sample error (Coaster::TestStandardError::SampleError)", e.to_s
      assert_equal "Test sample error (Coaster::TestStandardError::SampleError)", e.message
      assert_equal "Test sample error", e.description
      assert_equal "Test sample error", e.desc
      assert_equal "Test sample error", e._translate
      assert_equal "Test sample error", e.user_message
      e = SampleError.new(m: 'developer message', desc: 'user message')
      assert_equal "user message (developer message)", e.to_s
      assert_equal "user message (developer message)", e.message
      assert_equal 'user message', e.description
      assert_equal 'user message', e.desc
      assert_equal 'user message', e._translate
      assert_equal 'user message', e.user_message
      assert_equal 'Test this title', e.title
      e = SampleError.new(tkey: 'sample.interpolation', value: 'blah')
      assert_equal "Sample Interpolation blah (Coaster::TestStandardError::SampleError)", e.to_s
      assert_equal "Sample Interpolation blah (Coaster::TestStandardError::SampleError)", e.message
      assert_nil e.description
      assert_nil e.desc
      assert_equal 'Sample Interpolation blah', e._translate
      assert_equal 'Sample Interpolation blah', e.user_message
      assert_equal 'Test this title', e.title
    end

    def test_message
      raise SampleError, {m: 'beer is proof'}
    rescue => e
      assert_equal "Test sample error (beer is proof)", e.message
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
      assert_equal "Test example error (Coaster::TestStandardError::ExampleError) {Test sample error (Coaster::TestStandardError::SampleError)}", e.to_hash['message']
      assert_equal 'rams', e.to_hash['cause']['frog']
      assert_equal 'Coaster::TestStandardError::SampleError', e.to_hash['cause']['type']
      assert_equal 10, e.to_hash['cause']['status']
      assert_equal 500, e.to_hash['cause']['http_status']
      assert_equal "Test sample error (Coaster::TestStandardError::SampleError)", e.to_hash['cause']['message']
    end

    def test_cause_attributes
      begin
        raise SampleError, {frog: 'rams'}
      rescue => e
        raise ExampleError, {m: 'abc', wat: 'cha'}
      end
    rescue => e
      assert_equal 'Test example error (abc) {Test sample error (Coaster::TestStandardError::SampleError)}', e.message
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
	MESSAGE: Test example error (Coaster::TestStandardError::ExampleError) {Test sample error (Coaster::TestStandardError::SampleError)}
	@fingerprint: []
	@tags: {}
	@level: \"error\"
	@attributes: {\"frog\"=>\"rams\", \"wat\"=>\"cha\"}
	@tkey: nil
	@raven: {}
	CAUSE: [Coaster::TestStandardError::SampleError] status:10
		MESSAGE: Test sample error (Coaster::TestStandardError::SampleError)
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
      assert_equal 'standard error title', e.title
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
        assert_equal "a", e.root_cause.message
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
