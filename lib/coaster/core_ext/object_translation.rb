require 'i18n'

class Object
  class << self
    def _translate(*args)
      options = args.last.is_a?(Hash) ? args.pop.dup : {}
      options.merge!(_translate_params)

      key = args.shift
      subkey = nil

      if key.is_a?(String)
        if key.start_with?('.')
          subkey = key
        else
          return I18n.t(key, *args, options)
        end
      elsif key.is_a?(Symbol)
        subkey = ".#{key.to_s}"
      elsif key.nil?
        # do nothing
      else
        return I18n.t(key, *args, options)
      end

      key_class = options.delete(:class) || self
      subkey = '.self' unless subkey
      key = key_class.name.gsub(/::/, '.')
      key = 'class.' + key + subkey

      unless options.key?(:original_throw)
        options[:original_throw] = options.delete(:throw)
      end
      options[:tkey] ||= key
      options.merge!(throw: true)
      result = catch(:exception) do
        I18n.t(key, *args, options)
      end

      if result.is_a?(I18n::MissingTranslation)
        Coaster.logger && Coaster.logger.warn(result)
        unless options.key?(:original_missing)
          options.merge!(original_missing: result)
        end

        if key_class.superclass == Object || key_class == Object
          return options[:description] if options[:description].present?
          throw :exception, result if options[:original_throw]
          missing = options[:original_missing] || result
          msg = missing.message
          msg.instance_variable_set(:@missing, missing)
          msg.instance_variable_set(:@tkey, options[:tkey])
          msg
        else
          options[:class] = key_class.superclass
          _translate(subkey, *args, options)
        end
      else
        result.instance_variable_set(:@translated, true)
        result.instance_variable_set(:@tkey, options[:tkey])
        result
      end
    end

    def _translate_params
      {}
    end
  end

  # Foo::Bar.new._translate            #=> return translation 'class.Foo.Bar.self'
  # Foo::Bar.new._translate('.title')  #=> return translation 'class.Foo.Bar.title'
  # Foo::Bar.new._translate('title')   #=> return translation 'title'
  # Foo::Bar.new._translate(:force)    #=> ignore 'message' even if message exists
  #
  def _translate(*args)
    options = args.last.is_a?(Hash) ? args.pop.dup : {}
    key = args.shift || (respond_to?(:tkey) ? tkey : nil)

    if respond_to?(:description) && description.present? && description != 'false' && description != self.class.name
      if !key.is_a?(String) && key != :force
        return description
      else
        options.merge!(description: description)
      end
    end

    options.merge!(_translate_params)
    self.class._translate(key, *args, options)
  end

  def _translate_params
    {}
  end
end
