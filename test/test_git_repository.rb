require 'test_helper'
require 'minitest/autorun'
require 'coaster/git'

module Coaster
  class TestGitRepository < Minitest::Test
    def setup
      super
      @test_repo_root = File.expand_path('../../tmp/test_repo', __FILE__)
      FileUtils.rm_rf(@test_repo_root)
      FileUtils.mkdir_p(@test_repo_root)
      @beta = Coaster::Git.create(File.join(@test_repo_root, 'beta'))
      @beta.run_cmd('echo "hello beta" > README.md')
      @beta.add('.')
      @beta.run_git_cmd('commit -m "hello"')
      @beta.branch('beta_feature')
      @beta.checkout('beta_feature')
      @beta.run_cmd('echo "beta_feature" >> README.md')
      @beta.add('.')
      @beta.run_git_cmd('commit -m "beta_feature"')
      @beta.run_git_cmd('checkout main')

      @alpha = Coaster::Git.create(File.join(@test_repo_root, 'alpha'))
      @alpha.with_git_options({'-c' => {'protocol.file.allow' => 'always'}}) do
        @alpha.submodule_add!(@beta.path, 'sb/beta')
      end
      @alpha.submodule_update!('sb/beta')
      @alpha.run_cmd('echo "hello alpha" > README.md')
      @alpha.add('.')
      @alpha.run_git_cmd('commit -m "hello"')
    end

    def teardown
      FileUtils.rm_rf(@test_repo_root)
      super
    end

    def test_git_deep_merge
      assert_equal "hello alpha\n", @alpha.run_cmd('cat README.md')
      assert_equal "hello beta\n", @alpha.run_cmd('cat sb/beta/README.md')

      @alpha.branch('alpha_feature')
      @alpha.checkout('alpha_feature')
      @alpha.run_cmd('echo "alpha_feature" >> README.md')
      @alpha.submodules['sb/beta'].run_git_cmd('checkout beta_feature')
      @alpha.add('.')
      @alpha.run_git_cmd('commit -m "alpha_feature"')
      assert_equal "README.md\nsb/beta\n", @alpha.run_git_cmd('diff --name-only HEAD~1 HEAD')

      @alpha.checkout('main')
      @alpha.submodule_update!
      @alpha.submodules['sb/beta'].run_cmd('echo "main new commit" >> README2.md')
      @alpha.submodules['sb/beta'].add('.')
      @alpha.submodules['sb/beta'].run_git_cmd('commit -m "main new commit"')
      @alpha.add('.')
      @alpha.run_git_cmd('commit -m "main new commit"')
      assert_equal "hello beta\n", @alpha.run_cmd('cat sb/beta/README.md')

      @alpha.deep_merge('alpha_feature')
      assert_equal "hello alpha\nalpha_feature\n", @alpha.run_cmd('cat README.md')
      assert_equal "hello beta\nbeta_feature\n", @alpha.run_cmd('cat sb/beta/README.md')
    end
  end
end
