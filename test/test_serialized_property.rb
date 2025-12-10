require 'test_helper'
require 'minitest/autorun'

module Coaster
  class TestSerializedProperty < Minitest::Test
    def setup
    end

    def teardown
    end

    def test_serialized
      user = User.create(name: 'abc')
      assert_equal([:appendix, :simple, :father_id, :mother_id], User.serialized_property_settings.keys)
      user.init_appendix
      assert_equal 0, user.appendix['test_key1']
      assert_equal 0, user.appendix['test_key2']
      father = User.create(name: 'father')
      user.father = father
      assert_equal father, user.father
      assert_equal father.id, user.father_id
      mother = User.create(name: 'mother')
      user.mother = mother
      assert_equal mother, user.mother
      assert_equal mother.id, user.mother_id
      assert_equal({"appendix"=>{"test_key1"=>0, "test_key2"=>0}, "father_id"=>father.id, "mother_id"=>mother.id}, user.data)
      assert_equal({"appendix" => [nil, {"test_key1" => 0, "test_key2" => 0}], "father_id" => [nil, father.id], "mother_id" => [nil, mother.id]}, user.sprop_changes)
      assert_equal(true, user.mother_id_changed?)
      assert_equal(nil, user.mother_id_was)
      user.save!
      assert_equal(false, user.mother_id_changed?)
      assert_equal(true, user.mother_id_previously_changed?)
      assert_equal(nil, user.mother_id_previously_was)
      user = User.find(user.id)
      assert_equal({"appendix"=>{"test_key1"=>0, "test_key2"=>0}, "father_id"=>father.id, "mother_id"=>mother.id}, user.data)
      assert_equal mother, user.mother
      assert_equal father, user.father
      user.write_attribute(:simple, 100)
      assert_equal(100, user.read_attribute(:simple))
    end

    def test_active_record_attribute_methods
      user = User.create(name: 'test_ar')

      # Test write_attribute / read_attribute
      user.write_attribute(:simple, 'test_value')
      assert_equal 'test_value', user.read_attribute(:simple)
      assert_equal 'test_value', user.simple

      # Test [] / []= accessors
      user[:simple] = 'bracket_value'
      assert_equal 'bracket_value', user[:simple]
      assert_equal 'bracket_value', user.simple

      # Verify it's stored in the serialized column
      assert_equal 'bracket_value', user.data['simple']

      # Test that changes are persisted
      user.save!
      user.reload
      assert_equal 'bracket_value', user.simple
      assert_equal 'bracket_value', user.read_attribute(:simple)
      assert_equal 'bracket_value', user[:simple]
    end

    def test_dirty_tracking_with_will_change
      user = User.create(name: 'test_dirty')

      # Initially no changes
      assert_equal false, user.simple_changed?

      # After setting value, should be marked as changed
      user.simple = 'new_value'
      assert_equal true, user.simple_changed?
      assert_equal [nil, 'new_value'], user.simple_change

      # Save and verify previous change tracking
      user.save!
      assert_equal false, user.simple_changed?
      assert_equal true, user.simple_previously_changed?
      assert_equal [nil, 'new_value'], user.simple_previous_change

      # Update again
      user.simple = 'updated_value'
      assert_equal true, user.simple_changed?
      assert_equal 'new_value', user.simple_was
      user.save!
      assert_equal 'new_value', user.simple_previously_was
    end

    def test_default_value_persistence
      user = User.create(name: 'test_default')

      # appendix has default: {}
      # Modifying the returned hash should persist to data
      user.appendix['key1'] = 'value1'
      assert_equal 'value1', user.appendix['key1']
      assert_equal({'key1' => 'value1'}, user.data['appendix'])

      # Verify persistence after save
      user.save!
      user.reload
      assert_equal 'value1', user.appendix['key1']
    end

    def test_inherited_model_serialized_properties
      # Student inherits from User and has its own serialized properties
      student = Student.create(name: 'test_student')

      # Should have access to parent's serialized properties
      student.simple = 'inherited_value'
      assert_equal 'inherited_value', student.simple

      # Should have access to parent's default property
      student.appendix['parent_key'] = 'parent_value'
      assert_equal 'parent_value', student.appendix['parent_key']

      # Should have access to own serialized properties
      student.grade = 'A'
      assert_equal 'A', student.grade

      # Should have access to own default property
      student.scores['math'] = 95
      student.scores['english'] = 88
      assert_equal 95, student.scores['math']
      assert_equal 88, student.scores['english']

      # Verify data structure
      assert_equal 'inherited_value', student.data['simple']
      assert_equal 'A', student.data['grade']
      assert_equal({'parent_key' => 'parent_value'}, student.data['appendix'])
      assert_equal({'math' => 95, 'english' => 88}, student.data['scores'])

      # Verify persistence
      student.save!
      student.reload
      assert_equal 'inherited_value', student.simple
      assert_equal 'A', student.grade
      assert_equal 'parent_value', student.appendix['parent_key']
      assert_equal 95, student.scores['math']
    end

    def test_inherited_model_attribute_methods
      student = Student.create(name: 'test_student_ar')

      # Test write_attribute / read_attribute for inherited property
      student.write_attribute(:simple, 'write_test')
      assert_equal 'write_test', student.read_attribute(:simple)

      # Test write_attribute / read_attribute for own property
      student.write_attribute(:grade, 'B+')
      assert_equal 'B+', student.read_attribute(:grade)

      # Test [] / []= for inherited property
      student[:simple] = 'bracket_inherited'
      assert_equal 'bracket_inherited', student[:simple]

      # Test [] / []= for own property
      student[:grade] = 'A-'
      assert_equal 'A-', student[:grade]
    end

    def test_inherited_model_dirty_tracking
      student = Student.create(name: 'test_student_dirty')

      # Test dirty tracking for inherited property
      student.simple = 'new_simple'
      assert_equal true, student.simple_changed?

      # Test dirty tracking for own property
      student.grade = 'A'
      assert_equal true, student.grade_changed?

      student.save!
      assert_equal false, student.simple_changed?
      assert_equal false, student.grade_changed?
      assert_equal true, student.simple_previously_changed?
      assert_equal true, student.grade_previously_changed?
    end

    def test_inherited_model_settings
      # Student should have both parent's and own property settings via serialized_property_setting
      assert Student.serialized_property_setting(:appendix), 'should access parent appendix'
      assert Student.serialized_property_setting(:simple), 'should access parent simple'
      assert Student.serialized_property_setting(:grade), 'should access own grade'
      assert Student.serialized_property_setting(:scores), 'should access own scores'

      # serialized_property_settings should include both parent and own settings
      all_settings = Student.serialized_property_settings
      assert all_settings[:appendix], 'should include parent appendix'
      assert all_settings[:simple], 'should include parent simple'
      assert all_settings[:grade], 'should include own grade'
      assert all_settings[:scores], 'should include own scores'

      # own_serialized_property_settings should only include own settings
      own_settings = Student.own_serialized_property_settings
      assert_nil own_settings[:appendix], 'should not include parent appendix'
      assert_nil own_settings[:simple], 'should not include parent simple'
      assert own_settings[:grade], 'should include own grade'
      assert own_settings[:scores], 'should include own scores'
    end

    def test_getter_transforms_on_read
      student = Student.create(name: 'test_getter')

      # Set raw value via write_attribute (bypasses setter)
      student.write_attribute(:score_percentage, 85)
      assert_equal '85%', student.score_percentage

      # Verify raw value in data
      assert_equal 85, student.data['score_percentage']

      # Persistence
      student.save!
      student.reload
      assert_equal '85%', student.score_percentage
    end

    def test_setter_transforms_on_write
      student = Student.create(name: 'test_setter')

      # Set via setter - should transform to uppercase
      student.uppercase_name = 'john doe'
      assert_equal 'JOHN DOE', student.uppercase_name
      assert_equal 'JOHN DOE', student.data['uppercase_name']

      # Persistence
      student.save!
      student.reload
      assert_equal 'JOHN DOE', student.uppercase_name
    end

    def test_write_attribute_bypasses_setter
      student = Student.create(name: 'test_write_attr')

      # write_attribute should NOT apply setter transformation
      student.write_attribute(:uppercase_name, 'lowercase')
      assert_equal 'lowercase', student.uppercase_name
      assert_equal 'lowercase', student.data['uppercase_name']

      # But setter should apply transformation
      student.uppercase_name = 'another value'
      assert_equal 'ANOTHER VALUE', student.uppercase_name
    end

    def test_getter_and_setter_together
      student = Student.create(name: 'test_both')

      # Set value - setter encodes to Base64
      student.encrypted_value = 'secret data'

      # Raw value should be Base64 encoded
      raw_value = student.data['encrypted_value']
      assert_equal 'c2VjcmV0IGRhdGE=', raw_value

      # Getter should decode
      assert_equal 'secret data', student.encrypted_value

      # Persistence
      student.save!
      student.reload
      assert_equal 'secret data', student.encrypted_value
      assert_equal 'c2VjcmV0IGRhdGE=', student.data['encrypted_value']
    end

    def test_time_type_property
      Time.zone = 'UTC'
      student = Student.create(name: 'test_time')
      time = Time.zone.parse('2024-06-15 10:30:00 UTC')

      # Use the _without_callback= method which applies setter via _define_serialized_property
      student.enrolled_at_without_callback = time

      # Raw value should be ISO8601 string (setter transforms Time to string)
      raw_value = student.data['enrolled_at']
      assert raw_value.is_a?(String), "Expected String but got #{raw_value.class}"
      assert raw_value.include?('2024-06-15')

      # getter transforms string back to Time
      assert_equal time.to_i, student.enrolled_at.to_i

      # Persistence
      student.save!
      student.reload
      assert_equal time.to_i, student.enrolled_at.to_i
    end

    def test_unix_epoch_type_property
      Time.zone = 'UTC'
      student = Student.create(name: 'test_unix')
      time = Time.zone.parse('2024-06-15 10:30:00 UTC')

      # Use the _without_callback= method which applies setter
      student.graduated_at = time

      # Raw value should be integer timestamp (setter transforms Time to integer)
      raw_value = student.data['graduated_at']
      assert raw_value.is_a?(Integer), "Expected Integer but got #{raw_value.class}"
      assert_equal time.to_i, raw_value

      # getter transforms integer back to Time
      assert_equal time.to_i, student.graduated_at.to_i

      # Persistence
      student.save!
      student.reload
      assert_equal time.to_i, student.graduated_at.to_i
    end

    def test_time_type_with_direct_data_assignment
      Time.zone = 'UTC'
      student = Student.create(name: 'test_time_direct')

      student.enrolled_at = Time.parse('2024-01-01T00:00:00.000000Z')
      assert '2024-01-01T00:00:00.000000Z', student.data['enrolled_at']
      student.graduated_at = Time.parse('2028-01-01T00:00:00.000000Z')
      assert Time.parse('2028-01-01T00:00:00.000000Z').to_i, student.data['graduated_at']

      # getter transforms string to Time
      assert student.enrolled_at.is_a?(ActiveSupport::TimeWithZone)
      assert_equal 2024, student.enrolled_at.year

      teacher = User.create(name: 'Dr john')
      student.teacher = teacher
      student.save
      student = User.find(student.id)
      assert teacher.id, student.data['teacher_id']
      assert User, student.teacher.class
      assert teacher.id, student.teacher.id
    end

    def test_read_attribute_applies_getter
      student = Student.create(name: 'test_read_getter')

      # Set raw value directly in data
      student.data['score_percentage'] = 85

      # read_attribute should apply getter (adds %)
      assert_equal '85%', student.read_attribute(:score_percentage)

      # Same with [] accessor
      assert_equal '85%', student[:score_percentage]
    end

    def test_read_attribute_with_time_type
      Time.zone = 'UTC'
      student = Student.create(name: 'test_read_time')

      # Set ISO8601 string directly
      student.data['enrolled_at'] = '2024-06-15T10:30:00.000000Z'

      # Note: type: Time creates getter in _define_serialized_property,
      # but it's not stored in settings, so read_attribute returns raw value
      # The property accessor (enrolled_at) applies the getter
      result = student.read_attribute(:enrolled_at)
      assert result.is_a?(String), "read_attribute returns raw value for type: Time"

      # Property accessor applies getter
      result2 = student.enrolled_at
      assert result2.is_a?(ActiveSupport::TimeWithZone)
      assert_equal 2024, result2.year
    end

    def test_nil_value_with_getter_setter
      student = Student.create(name: 'test_nil')

      # Set then clear
      student.encrypted_value = 'some value'
      assert_equal 'some value', student.encrypted_value

      student.encrypted_value = nil
      assert_nil student.encrypted_value
      assert_nil student.data['encrypted_value']
    end
  end
end