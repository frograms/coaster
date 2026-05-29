require 'test_helper'
require 'minitest/autorun'

module Coaster
  # Regression: a falsey default (`default: false`) must behave like any other
  # default. The reader must return `false` when the key is unset, and the
  # lazy-seed must not leak to the DB.
  #
  # Before the fix, `_define_serialized_property` branched on `if default` at
  # definition time, so `default: false` fell into the no-default reader branch
  # and an unset property read as `nil` instead of `false`.
  class TestSerializedPropertyFalseyDefault < Minitest::Test
    class BoolUser < User
      serialized_property :data, :verified, default: false
      serialized_property :data, :enabled,  default: true
    end

    # --- default: false (the bug) ---

    # The core regression: an unset falsey default must read as false, not nil.
    def test_false_default_reads_as_false_when_unset
      u = BoolUser.create!(name: 'f_unset')
      assert_equal false, u.verified, 'default: false must read as false, not nil'
    end

    # A pure read seeds the default in memory but it must be stripped on save,
    # exactly like a truthy default.
    def test_false_default_bare_read_not_persisted
      u = BoolUser.create!(name: 'f_read')
      u.verified # reader seeds data['verified'] = false in memory
      u.save!
      u.reload
      refute u.data.key?('verified'), 'default-equal false must be stripped before save'
      assert_equal false, u.verified
    end

    # reader 호출 여부가 DB 적재 결과를 바꾸면 안 된다 (write parity).
    def test_false_default_write_parity
      read = BoolUser.create!(name: 'f_par_r')
      read.verified
      read.save!
      read.reload

      noread = BoolUser.create!(name: 'f_par_n')
      noread.save!
      noread.reload

      assert_equal read.data.key?('verified'), noread.data.key?('verified')
      refute read.data.key?('verified')
    end

    # A value differing from the default (true) must persist and read back.
    def test_false_default_explicit_true_persists
      u = BoolUser.create!(name: 'f_true', verified: true)
      u.reload
      assert_equal true, u.data['verified'], 'non-default true must persist'
      assert_equal true, u.verified
    end

    # --- default: true (regression guard, already worked) ---

    def test_true_default_reads_as_true_when_unset
      u = BoolUser.create!(name: 't_unset')
      assert_equal true, u.enabled
    end

    def test_true_default_explicit_false_persists
      u = BoolUser.create!(name: 't_false', enabled: false)
      u.reload
      assert_equal false, u.data['enabled'], 'non-default false must persist'
      assert_equal false, u.enabled
    end
  end
end
