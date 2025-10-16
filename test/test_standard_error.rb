require 'test_helper'
require 'minitest/autorun'
require 'coaster/core_ext/standard_error/sentry'

StandardError.inspection_value_proc = Proc.new do |val|
  PP.pp(val, ''.dup, 79)[0...-1]
end

StandardError.cleaner = ActiveSupport::BacktraceCleaner.new
StandardError.cause_cleaner = StandardError.cleaner

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
      assert_equal 'standard error translation (363fdc)', e.user_message
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
      assert_equal 'standard error translation (e39e84)', e.user_message
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
      assert_equal "Translation missing: en.no.translation (Coaster::TestStandardError::UntitledError)", e.to_s
      assert_equal "Translation missing: en.no.translation (Coaster::TestStandardError::UntitledError)", e.message
      assert_nil e.description
      assert_nil e.desc
      assert_equal 'Translation missing: en.no.translation', e._translate
      assert_equal "Translation missing: en.no.translation", e.user_message
      assert_equal 'standard error title', e.title
    end

    def test_with_translation_class
      e = SampleError.new
      assert_equal "Coaster::TestStandardError::SampleError", e.to_s
      assert_equal "Coaster::TestStandardError::SampleError", e.message
      assert_nil e.description
      assert_nil e.desc
      assert_equal 'Test sample error', e._translate
      assert_equal 'Test sample error (6cef86)', e.user_message
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
      assert_equal 'Test sample error (43161e)', e.user_message
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
      assert_equal "Test example error (Coaster::TestStandardError::ExampleError) cause{Test sample error (Coaster::TestStandardError::SampleError)}", e.to_hash['message']
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
      assert_equal 'Test example error (abc) cause{Test sample error (Coaster::TestStandardError::SampleError)}', e.message
      assert_equal 'rams', e.cause.attr['frog']
      assert_equal 'rams', e.attr['frog']
      assert_equal 'cha', e.attr['wat']
    end

    def test_to_detail
      begin
        raise SampleError, {frog: 'rams'}
      rescue => e
        err = ExampleError.new(wat: 'cha')
        err.instance_variable_set(:@ins_var, [SampleError.new, {h: 1}])
        err.instance_variable_set(:@ins_varr, {dd: true})
        raise err
      end
    rescue => e
      ih = e.to_inspection_hash
      assert_equal 'Coaster::TestStandardError::ExampleError', ih['type']
      assert_equal 20, ih['status']
      assert_equal 500, ih['http_status']
      assert_equal "Test example error (Coaster::TestStandardError::ExampleError) cause{Test sample error (Coaster::TestStandardError::SampleError)}", ih['message']
      assert ih['instance_variables']['@coaster']
      assert_instance_of Array, ih['backtrace']
      assert_equal 'Coaster::TestStandardError::SampleError', ih['cause']['type']
      assert_equal 10, ih['cause']['status']
      assert_equal 500, ih['cause']['http_status']
      assert_equal "Test sample error (Coaster::TestStandardError::SampleError)", ih['cause']['message']
      assert ih['cause']['instance_variables']['@coaster']
      assert_instance_of Array, ih['cause']['backtrace']
      assert_equal [e.digest_message, e.digest_backtrace], e.sentry_fingerprint

      detail = e.to_inspection_s
      detail_front = <<-LOG
[Coaster::TestStandardError::ExampleError] status:20
  MESSAGE: Test example error (Coaster::TestStandardError::ExampleError) cause{Test sample error (Coaster::TestStandardError::SampleError)}
  @attributes: {\"frog\" => \"rams\", \"wat\" => \"cha\"}
  @coaster: true
  @digest_backtrace: #{e.digest_backtrace}
  @digest_message: a8c7c1
  @fingerprint: []
  @ins_var: [\"Coaster::TestStandardError::SampleError\", {\"h\" => 1}]
  @ins_varr: {\"dd\" => true}
  @level: \"error\"
  @raven: {}
  @tags: {}
  @tkey: nil
  BACKTRACE:
    #{__FILE__}:193:in 'Coaster::TestStandardError#test_to_detail'
LOG
      detail_cause_front = <<-LOG
CAUSE: [Coaster::TestStandardError::SampleError] status:10
    MESSAGE: Test sample error (Coaster::TestStandardError::SampleError)
    @attributes: {"frog" => "rams"}
    @coaster: true
    @digest_backtrace: #{e.cause.digest_backtrace}
    @digest_message: cbe233
    @fingerprint: []
    @level: "error"
    @raven: {}
    @tags: {}
    @tkey: nil
    BACKTRACE:
      #{__FILE__}:188:in 'Coaster::TestStandardError#test_to_detail'
LOG
      assert_match(/^#{Regexp.escape(detail_front)}/, detail)
      cause_ix = (detail =~ /CAUSE/)
      cause = detail[cause_ix..-1]
      assert_match(/^#{Regexp.escape(detail_cause_front)}/, cause)
    end

    def test_to_detail_with_depth
      begin
        begin
          begin
            begin
              begin
                raise SampleError
              rescue => e
                raise SampleError
              end
            rescue => e
              raise SampleError
            end
          rescue => e
            raise SampleError
          end
        rescue => e
          raise SampleError
        end
      rescue => e
        raise SampleError
      end
    rescue => e
      detail = e.to_inspection_s
      assert detail =~ /and more causes/
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
      bt = e.digest_backtrace
      assert_equal 'NameError', e.to_hash['type']
      assert_equal 999999, e.to_hash['status']
      assert_equal 500, e.to_hash['http_status']
      assert_equal "standard error translation (#{e.digest_message} #{bt})", e.user_message
      assert_match(/undefined local variable or method 'aa'/, e.to_hash['message'])
    end

    def test_descriptions
      raise SampleError
    rescue => e
      e.descriptions.merge!(a: 1)
      assert_equal 1, e.descriptions['a']
    end

    def test_to_json
      raise SampleError
    rescue => e
      json = ::JSON.dump({error: e})
      assert_equal "{\"error\":{\"type\":\"Coaster::TestStandardError::SampleError\",\"status\":10,\"http_status\":500,\"message\":\"Coaster::TestStandardError::SampleError\"}}", json
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

    def test_user_message_change
      SampleErrorSub.user_digests_with! do
        message
      end

      begin
        raise SampleError, 'asdff'
      rescue => e
        bt = e.digest_backtrace
        assert_equal "Test sample error (0dba9e #{bt})", e.user_message
      end
      begin
        raise SampleErrorSub, 'asdff'
      rescue => e
        assert_equal 'Test sample error (asdff)', e.user_message
      end
      begin
        raise SampleErrorSubSub, 'asdff'
      rescue => e
        assert_equal 'Test sample error (asdff)', e.user_message
      end

      SampleErrorSubSub.user_digests_with_default!
      begin
        raise SampleErrorSubSub, 'asdff'
      rescue => e
        bt = e.digest_backtrace
        assert_equal "Test sample error (58ee3f #{bt})", e.user_message
      end
    end

    def test_wrapping_digest
      a = StandardError.new('#<Abc:0x111>')
      b = StandardError.new(a)
      assert_equal '#<Abc:0x111>', b.message
    end
  end
end
