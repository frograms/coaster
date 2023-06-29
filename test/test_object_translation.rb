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
      assert_equal 'Translation missing: en.class.Coaster.NotTranslated.self', NotTranslated._translate
    end

    def test_fallback
      assert_equal 'Coaster::NotTranslated', NotTranslated._translate(fallback: :name)
      assert_equal 'aabbcc', NotTranslated._translate(fallback: 'aabbcc')
      assert_equal 'Coaster::NotTranslated..aabb', NotTranslated._translate(fallback: proc{|klass| "#{klass.name}..aabb"})
    end

    def test_raise_translation_missing
      exception = catch(:exception) do
        NotTranslated._translate(throw: true)
      end
      assert_equal(I18n::MissingTranslation, exception.class)
    end

    def test_translation_sub
      assert_equal 'Coaster SampleObject Title (class.Coaster.SampleObject.title)', SampleObject._translate('.title')
      assert_equal 'Coaster SampleObject Title (class.Coaster.SampleObject.title)', SampleObject._translate(:title)
      assert_nil SampleObject._translate(:title).instance_variable_get(:@missing)
    end

    def test_translation_with_key
      assert_equal 'Sample Title', SampleObject._translate('sample.title')
    end

    def test_translation_inheritance
      assert_equal 'Coaster SampleObject Translated', Inherited._translate
      assert_equal 'Coaster SampleObject Title (class.Coaster.Inherited.title)', Inherited._translate(:title)
      assert Inherited._translate.instance_variable_get(:@missing)
    end

    def test_interpolation
      assert_equal 'Coaster SampleObject interpolation test this interpolated', SampleObject._translate('.interpolation', {test_this: 'this interpolated'}.with_indifferent_access)
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
