require 'test_helper'
require 'minitest/autorun'

module Coaster

  class SampleObject < String
  end

  class NotTranslated
  end

  class Inherited < SampleObject
  end

  class TestObjectTranslation < Minitest::Test
    def setup
      I18n.backend = I18n::Backend::Simple.new
      I18n.load_path += [File.expand_path('../locales/en.yml', __FILE__)]
      I18n.enforce_available_locales = false
    end

    def test_translation
      assert_equal 'Coaster SampleObject Translated', SampleObject._translate
    end

    def test_translation_missing
      assert_equal 'translation missing: en.class.Coaster.NotTranslated.self', NotTranslated._translate
    end

    def test_translation_sub
      assert_equal 'Coaster SampleObject Title', SampleObject._translate('.title')
      assert_equal 'Coaster SampleObject Title', SampleObject._translate(:title)
    end

    def test_translation_with_key
      assert_equal 'Sample Title', SampleObject._translate('sample.title')
    end

    def test_translation_inheritance
      assert_equal 'Coaster SampleObject Translated', Inherited._translate
      assert_equal 'Coaster SampleObject Title', Inherited._translate(:title)
    end

    def teardown
      I18n.locale = nil
      I18n.default_locale = nil
      I18n.load_path = nil
      I18n.available_locales = nil
      I18n.backend = nil
      I18n.default_separator = nil
      I18n.enforce_available_locales = true
      super
    end
  end
end
