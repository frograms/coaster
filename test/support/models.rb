require 'coaster/serialized_properties'
require 'coaster/safe_yaml_serializer'

class User < ActiveRecord::Base
  serialize :data, coder: Coaster::SafeYamlSerializer
  extend Coaster::SerializedProperties
  serialized_column :data
  serialized_property :data, :appendix, default: {}
  serialized_property :data, :simple
  serialized_property :data, :father, type: :User
  serialized_property :data, :mother, type: self

  def init_appendix
    appendix['test_key1'] ||= 0
    appendix['test_key2'] ||= 0
  end
end

class Student < User
  serialized_property :data, :grade
  serialized_property :data, :scores, default: {}

  # Property with getter (transforms on read)
  serialized_property :data, :score_percentage,
    getter: ->(val) { val.nil? ? nil : "#{val}%" }

  # Property with setter (transforms on write)
  serialized_property :data, :uppercase_name,
    setter: ->(val) { val.to_s.upcase }

  # Property with both getter and setter
  serialized_property :data, :encrypted_value,
    getter: ->(val) { val.nil? ? nil : Base64.decode64(val) },
    setter: ->(val) { Base64.strict_encode64(val.to_s) }

  # Property with type: Time (uses ISO8601 string internally)
  serialized_property :data, :enrolled_at, type: Time

  # Property with type: :unix_epoch (uses integer timestamp internally)
  serialized_property :data, :graduated_at, type: :unix_epoch

  serialized_property :data, :teacher, type: 'User'
end
