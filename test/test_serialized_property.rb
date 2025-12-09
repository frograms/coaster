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
  end
end