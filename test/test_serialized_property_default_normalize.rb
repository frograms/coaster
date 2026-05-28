require 'test_helper'
require 'minitest/autorun'

module Coaster
  # Verifies the before_save normalize hook: a reader's lazy default-seed must
  # never reach the database, while real mutations are preserved.
  class TestSerializedPropertyDefaultNormalize < Minitest::Test
    # A pure read seeds default into the column hash in memory, but it must be
    # stripped before save so the DB row never gains the default key.
    def test_read_only_hash_default_not_persisted
      u = User.create(name: 'ro_hash')
      u.appendix # reader seeds data['appendix'] = {}
      assert_equal({}, u.data['appendix'], 'reader seeds default in memory')
      u.save!
      u.reload
      refute u.data.key?('appendix'), 'default-equal appendix must be stripped before save'
    end

    def test_read_only_array_default_not_persisted
      u = User.create(name: 'ro_arr')
      u.tags # reader seeds data['tags'] = []
      assert_equal([], u.data['tags'], 'reader seeds [] in memory')
      u.save!
      u.reload
      refute u.data.key?('tags'), 'default-equal tags must be stripped before save'
    end

    # Seeding the default on a persisted record during a read must not turn
    # into a real column change on save (no spurious UPDATE of that column).
    def test_read_only_seed_does_not_persist_change
      u = User.create(name: 'no_dirty')
      u.reload
      u.tags # seeds default []
      u.save!
      refute u.saved_change_to_data?, 'seeding a default on read must not produce a real data change'
    end

    # A real mutation produces a value different from the default and survives.
    def test_array_mutation_preserved
      u = User.create(name: 'mut_arr')
      u.tags << 'a'
      u.tags << 'b'
      u.save!
      u.reload
      assert_equal(%w[a b], u.data['tags'], 'non-default array value must persist')
      assert_equal(%w[a b], u.tags)
    end

    def test_hash_mutation_preserved
      u = User.create(name: 'mut_hash')
      u.appendix['k'] = 'v'
      u.save!
      u.reload
      assert_equal({ 'k' => 'v' }, u.data['appendix'])
    end

    # A value mutated and then reset back to its default is stripped again.
    def test_value_reset_to_default_is_stripped
      u = User.create(name: 'reset')
      u.tags << 'x'
      u.save!
      u.reload
      assert_equal(['x'], u.data['tags'])

      u.tags.delete('x') # now [] == default
      u.save!
      u.reload
      refute u.data.key?('tags'), 'tags reset to default must be stripped'
    end

    # An untouched persisted record with no seeded defaults stays a no-op.
    def test_untouched_record_save_is_noop
      u = User.create(name: 'untouched')
      u.reload
      u.save!
      refute u.saved_change_to_data?
    end

    # A meaningful change on one key must not strip a sibling non-default key.
    def test_sibling_keys_independent
      u = User.create(name: 'siblings')
      u.appendix['k'] = 'v'   # non-default
      u.tags                  # default-seeded [] -> should be stripped
      u.save!
      u.reload
      assert_equal({ 'k' => 'v' }, u.data['appendix'])
      refute u.data.key?('tags'), 'default tags stripped even when sibling key persists'
    end
  end
end
