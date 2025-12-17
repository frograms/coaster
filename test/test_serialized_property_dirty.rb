require 'test_helper'
require 'minitest/autorun'

module Coaster
  class TestSerializedProperty < Minitest::Test
    def setup
    end

    def teardown
    end

    def test_dirty
      user = User.create(name: 'abc')
      mother = User.create(name: 'mother')
      user.mother = mother
      assert_equal mother, user.mother
      assert_equal mother.id, user.mother_id
      assert_equal({"mother_id"=>mother.id}, user.data)
      assert_equal({"data" => [{}, {"mother_id"=>mother.id}]}, user.changes)
      assert_equal({"mother_id" => [nil, mother.id]}, user.sprop_changes)
      assert_equal(true, user.mother_id_changed?)
      assert_equal(nil, user.mother_id_was)
      user.save!
      user = User.find(user.id)
      user.mother_id = mother.id
      assert_equal(false, user.mother_id_changed?)
      assert_equal({}, user.changes)
      step_mother = User.create(name: 'step_mother')
      user.mother = step_mother
      assert_equal({"data" => [{"mother_id" => mother.id}, {"mother_id" => step_mother.id}]}, user.changes)
      assert_equal({"mother_id" => [mother.id, step_mother.id]}, user.sprop_changes)
    end

    # Tests for dirty tracking optimization (skip dirty marking when value unchanged)
    def test_same_value_setter_does_not_mark_dirty
      user = User.create(name: 'test_same_value')
      user.simple = 'initial_value'
      user.save!

      # Reload to clear dirty state
      user.reload
      assert_equal false, user.changed?

      # Set same value - should NOT mark dirty
      user.simple = 'initial_value'
      assert_equal false, user.simple_changed?, 'Setting same value should not mark property as changed'
      assert_equal false, user.changed?, 'Setting same value should not mark record as changed'
    end

    def test_different_value_setter_marks_dirty
      user = User.create(name: 'test_different_value')
      user.simple = 'initial_value'
      user.save!
      user.reload

      # Set different value - should mark dirty
      user.simple = 'new_value'
      assert_equal true, user.simple_changed?, 'Setting different value should mark property as changed'
      assert_equal true, user.changed?, 'Setting different value should mark record as changed'
      assert_equal ['initial_value', 'new_value'], user.simple_change
    end

    def test_nil_to_value_marks_dirty
      user = User.create(name: 'test_nil_to_value')
      user.save!
      user.reload

      assert_nil user.simple
      user.simple = 'some_value'
      assert_equal true, user.simple_changed?
      assert_equal [nil, 'some_value'], user.simple_change
    end

    def test_value_to_nil_marks_dirty
      user = User.create(name: 'test_value_to_nil')
      user.simple = 'some_value'
      user.save!
      user.reload

      user.simple = nil
      assert_equal true, user.simple_changed?
      assert_equal ['some_value', nil], user.simple_change
    end

    def test_nil_to_nil_does_not_mark_dirty
      user = User.create(name: 'test_nil_to_nil')
      user.save!
      user.reload

      assert_nil user.simple
      user.simple = nil
      assert_equal false, user.simple_changed?, 'Setting nil to nil should not mark as changed'
      assert_equal false, user.changed?
    end

    def test_same_value_via_write_attribute_does_not_mark_dirty
      user = User.create(name: 'test_write_attr_same')
      user.write_attribute(:simple, 'initial')
      user.save!
      user.reload

      user.write_attribute(:simple, 'initial')
      assert_equal false, user.simple_changed?
      assert_equal false, user.changed?
    end

    def test_same_value_via_bracket_accessor_does_not_mark_dirty
      user = User.create(name: 'test_bracket_same')
      user[:simple] = 'initial'
      user.save!
      user.reload

      user[:simple] = 'initial'
      assert_equal false, user.simple_changed?
      assert_equal false, user.changed?
    end

    def test_same_value_with_setter_proc_does_not_mark_dirty
      student = Student.create(name: 'test_setter_same')
      student.uppercase_name = 'hello'  # Stored as 'HELLO'
      student.save!
      student.reload

      # Setting same raw input - setter transforms to same value
      student.uppercase_name = 'hello'
      assert_equal false, student.uppercase_name_changed?, 'Same value after setter transform should not mark dirty'
      assert_equal false, student.changed?
    end

    def test_different_case_with_setter_proc_marks_dirty
      student = Student.create(name: 'test_setter_diff')
      student.uppercase_name = 'hello'  # Stored as 'HELLO'
      student.save!
      student.reload

      # Setting different value
      student.uppercase_name = 'world'  # Stored as 'WORLD'
      assert_equal true, student.uppercase_name_changed?
      assert_equal ['HELLO', 'WORLD'], student.uppercase_name_change
    end
  end
end
