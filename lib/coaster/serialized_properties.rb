module Coaster
  module SerializedProperties
    class DuplicatedProperty < StandardError; end
    class InvalidProperty < StandardError; end

    def self.extended(base)
      base.class_eval do
        def sprop_changes = self.class.serialized_property_changes(changes)
        def sprop_change(key) = sprop_changes[key.to_s]
        def sprop_changed?(key) = sprop_change(key).present?
        def sprop_was(key) = (ch = sprop_change(key)).present? ? ch[0] : nil
        
        def sprop_saved_changes = self.class.serialized_property_changes(saved_changes)
        def sprop_saved_change(key) = sprop_saved_changes[key.to_s]

        def sprop_previous_changes = self.class.serialized_property_changes(previous_changes)
        def sprop_previous_change(key) = sprop_previous_changes[key.to_s] 
        def sprop_previously_changed?(key) = sprop_previous_change(key).present?
        def sprop_previously_was(key) = (ch = sprop_previous_change(key)).present? ? ch[0] : nil
      end
    end

    def serialized_property_changes(changes)
      serialized_property_settings.each_with_object({}) do |(key, prop), result|
        prop_ch = changes[prop[:column].to_s]
        next if prop_ch.blank?
        before = prop_ch[0] && prop_ch[0][key.to_s]
        after = prop_ch[1] && prop_ch[1][key.to_s]
        result[key.to_s] = [before, after] if before != after
      end
    end

    def serialized_property_settings
      @serialized_property_settings ||= {}
    end

    def serialized_property_setting(key)
      serialized_property_settings[key.to_sym]
    end

    def serialized_column(serialize_column)
      define_method serialize_column.to_sym do
        return read_attribute(serialize_column.to_sym) if read_attribute(serialize_column.to_sym)
        write_attribute(serialize_column.to_sym, {})
        read_attribute(serialize_column)
      end
    end

    def serialized_property_comment(key)
      cm = serialized_property_settings[key.to_sym] &&
           serialized_property_settings[key.to_sym][:comment]
      cm || key.to_s
    end

    def serialized_property(serialize_column, key, type: nil, comment: nil, getter: nil, setter: nil, setter_callback: nil, default: nil, rescuer: nil)
      raise DuplicatedProperty, "#{self.name}##{key} duplicated\n#{caller[0..5].join("\n")}" if serialized_property_settings[key.to_sym]
      serialized_property_settings[key.to_sym] = {column: serialize_column.to_sym, type: type, comment: comment, getter: getter, setter: setter, setter_callback: setter_callback, default: default, rescuer: rescuer}
      _typed_serialized_property(serialize_column, key, type: type, getter: getter, setter: setter, setter_callback: setter_callback, default: default, rescuer: rescuer)
    end

    def serialized_properties(serialize_column, *keys, type: nil, getter: nil, setter: nil, setter_callback: nil, default: nil, rescuer: nil)
      keys.flatten.each do |key|
        key_name = key
        prop_hash = {type: type, getter: getter, setter: setter, setter_callback: setter_callback, default: default, rescuer: rescuer}
        if key.is_a? Hash
          key_name = key[:key]
          prop_hash = {type: type, getter: getter, setter: setter, setter_callback: setter_callback, default: default}.merge(key)
          prop_hash.delete(:key)
        end
        serialized_property(serialize_column, key_name, **prop_hash)
      end
    end

    private

    def _typed_serialized_property(serialize_column, key, type: nil, getter: nil, setter: nil, setter_callback: nil, default: nil, rescuer: nil)
      case type
        when String then
          # String은 나중에 eval해서 가져옴,
          # type에서 다른 객체를 참조할 경우, 순환참조가 발생할 수 있기 때문에
          Rails.configuration.after_initialize {
            if type.is_a?(String)
              begin
                type = eval(type)
                raise InvalidProperty, m: "#{self.name}##{key} type string is return string #{type}", type: type if type.is_a?(String)
              rescue InvalidProperty => e
                if rescuer
                  type = rescuer.call(e)
                else
                  raise
                end
              rescue => e
                e.attributes[:type] = type
                if rescuer
                  type = rescuer.call(e)
                else
                  raise InvalidProperty, "#{self.name}##{key} eval failed: type:[#{type}] [#{e.class.name}] #{e.message}"
                end
              end
              if type
                serialized_property_setting(key.to_sym)[:type] = type
                _typed_serialized_property serialize_column, key, type: type, getter: getter, setter: setter, setter_callback: setter_callback, default: default
              end
            end
          }
        when Array then
          _define_serialized_property serialize_column, key,
            setter: proc { |val|
              raise InvalidProperty, "#{self.name}##{key} must be one of #{type}" unless type.include?(val)
              val
            },
            getter: proc { |val|
              type.include?(val) ? val : nil
            },
            default: default
        else
          if type == Time
            _define_serialized_property serialize_column, key,
              getter: Proc.new { |val| val.nil? ? nil : Time.zone.parse(val) },
              setter: Proc.new { |val|
                if val.is_a?(Time)
                  val.utc.iso8601(6)
                end
              },
              default: default
          elsif type == :unix_epoch
            _define_serialized_property(serialize_column, key,
              getter: Proc.new { |val| val.nil? ? nil : Time.zone.at(val) },
              setter: Proc.new { |val|
                raise TypeError, "serialized_property: only time can be accepted: #{val.class}" unless val.is_a?(Time)
                val.to_i
              },
              default: default
            )
          elsif type == Integer
            _define_serialized_property serialize_column, key,
              setter: proc { |val|
                val = val.blank? ? nil : Integer(val)
                val = setter.call(val) if setter
                val
              },
              default: default
          elsif type == Array
            _define_serialized_property(serialize_column, key, default: default || [])
          elsif type.respond_to?(:serialized_property_serializer) && (serializer = type.serialized_property_serializer)
            _define_serialized_property(serialize_column, key, getter: serializer[:getter], setter: serializer[:setter], setter_callback: serializer[:setter_callback], default: default)
          elsif (type.is_a?(Symbol) && (t = type.to_s.constantize rescue nil)) || (type.is_a?(Class) && type < ActiveRecord::Base && (t = type))
            serialized_property_settings["#{key}_id".to_sym] = serialized_property_settings.delete(key.to_sym) # rename key from setting
            _define_serialized_property serialize_column, "#{key}_id", default: default

            define_method key.to_sym do
              instance_val = instance_variable_get("@#{key}".to_sym)
              return instance_val if instance_val
              key_id = send("#{key}_id".to_sym)
              if key_id.nil?
                instance_val = nil
              else
                instance_val = t.find(key_id) rescue nil
              end
              instance_val = getter.call(instance_val) if getter
              instance_variable_set("@#{key}".to_sym, instance_val)
              instance_val
            end

            define_method "#{key}=".to_sym do |val|
              val = setter.call(val) if setter

              if val.nil?
                instance_variable_set("@#{key}".to_sym, nil)
                send("#{key}_id=".to_sym, nil)
              else
                unless val.is_a?(t)
                  raise ActiveRecord::AssociationTypeMismatch, "#{t}(##{t.object_id}) expected, got #{val.class.name}(#{val.class.object_id})"
                end
                instance_variable_set("@#{key}".to_sym, val)
                send("#{key}_id=".to_sym, (Integer(val.id) rescue val.id))
              end

              if setter_callback
                setter_callback.call(val)
              else
                val
              end
            end
          else
            _define_serialized_property serialize_column, key, getter: getter, setter: setter, setter_callback: setter_callback, default: default
          end
      end
    end

    def _define_serialized_property(serialize_column, key, getter: nil, setter: nil, setter_callback: nil, default: nil)
      if default
        if getter
          define_method key.to_sym do
            hsh = send(serialize_column.to_sym)
            hsh[key.to_s] ||= default.dup
            getter.call(hsh[key.to_s])
          end
        else
          define_method key.to_sym do
            hsh = send(serialize_column.to_sym)
            hsh[key.to_s] ||= default.dup
            hsh[key.to_s]
          end
        end
      else
        if getter
          define_method key.to_sym do
            hsh = send(serialize_column.to_sym)
            getter.call(hsh[key.to_s])
          end
        else
          define_method key.to_sym do
            hsh = send(serialize_column.to_sym)
            hsh[key.to_s]
          end
        end
      end

      if setter
        define_method "#{key}_without_callback=".to_sym do |val|
          if val.nil?
            send(serialize_column.to_sym).delete(key.to_s)
          else
            val = setter.call(val) if setter
            send(serialize_column.to_sym)[key.to_s] = val
          end
        end
      else
        define_method "#{key}_without_callback=".to_sym do |val|
          if val.nil?
            send(serialize_column.to_sym).delete(key.to_s)
          else
            send(serialize_column.to_sym)[key.to_s] = val
          end
        end
      end

      if setter_callback
        define_method "#{key}=".to_sym do |val|
          send("#{key}_without_callback=".to_sym, val)
          setter_callback.call(val)
        end
      else
        define_method "#{key}=".to_sym do |val|
          send("#{key}_without_callback=".to_sym, val)
        end
      end

      define_method "#{key}_change".to_sym do
        send("sprop_change", key)
      end
      define_method "#{key}_changed?".to_sym do
        send("sprop_changed?", key)
      end
      define_method "#{key}_was".to_sym do
        send("sprop_was", key)
      end
      define_method "#{key}_previous_change".to_sym do
        send("sprop_previous_change", key)
      end
      define_method "#{key}_previously_changed?".to_sym do
        send("sprop_previously_changed?", key)
      end
      define_method "#{key}_previously_was".to_sym do
        send("sprop_previously_was", key)
      end
    end
  end
end
