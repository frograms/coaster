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
      user.save!
      user = User.find(user.id)
      assert_equal({"appendix"=>{"test_key1"=>0, "test_key2"=>0}, "father_id"=>father.id, "mother_id"=>mother.id}, user.data)
      assert_equal mother, user.mother
      assert_equal father, user.father
    end
  end
end