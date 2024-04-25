require 'coaster/serialized_properties'
require 'coaster/safe_yaml_serializer'

class User < ActiveRecord::Base
  serialize :data, Coaster::SafeYamlSerializer
  extend Coaster::SerializedProperties
  serialized_column :data
  serialized_property :data, :appendix, default: {}
  serialized_property :data, :father, type: :User
  serialized_property :data, :mother, type: self

  def init_appendix
    appendix['test_key1'] ||= 0
    appendix['test_key2'] ||= 0
  end
end
