require 'test_helper'
require 'minitest/autorun'

module Coaster
  class TestBacktrace < Minitest::Test
    def setup
      @backtrace = <<~EOS.chomp.split("\n")
        /home/circleci/project/app/controllers/application_controller.rb:174:in `block (2 levels) in block_fun'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/actionpack-6.1.4.4/lib/action_controller/metal/mime_responds.rb:214:in `respond_to'
        /home/circleci/project/app/controllers/application_controller.rb:170:in `block_fun'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/activesupport-6.1.4.4/lib/active_support/callbacks.rb:427:in `block in make_lambda'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/activesupport-6.1.4.4/lib/active_support/callbacks.rb:198:in `block (2 levels) in halting'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/actionpack-6.1.4.4/lib/abstract_controller/callbacks.rb:34:in `block (2 levels) in <module:Callbacks>'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/activesupport-6.1.4.4/lib/active_support/callbacks.rb:199:in `block in halting'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/activesupport-6.1.4.4/lib/active_support/callbacks.rb:512:in `block in invoke_before'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/activesupport-6.1.4.4/lib/active_support/callbacks.rb:512:in `each'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/activesupport-6.1.4.4/lib/active_support/callbacks.rb:512:in `invoke_before'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/activesupport-6.1.4.4/lib/active_support/callbacks.rb:115:in `block in run_callbacks'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/bundler/gems/vanity-ce67b2c66864/lib/vanity/frameworks/rails.rb:141:in `vanity_context_filter'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/activesupport-6.1.4.4/lib/active_support/callbacks.rb:126:in `block in run_callbacks'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/actiontext-6.1.4.4/lib/action_text/rendering.rb:20:in `with_renderer'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/actiontext-6.1.4.4/lib/action_text/engine.rb:59:in `block (4 levels) in <class:Engine>'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/activesupport-6.1.4.4/lib/active_support/callbacks.rb:126:in `instance_exec'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/activesupport-6.1.4.4/lib/active_support/callbacks.rb:126:in `block in run_callbacks'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/react-rails-2.6.1/lib/react/rails/controller_lifecycle.rb:31:in `use_react_component_helper'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/activesupport-6.1.4.4/lib/active_support/callbacks.rb:126:in `block in run_callbacks'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/activesupport-6.1.4.4/lib/active_support/callbacks.rb:137:in `run_callbacks'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/actionpack-6.1.4.4/lib/abstract_controller/callbacks.rb:41:in `process_action'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/actionpack-6.1.4.4/lib/action_controller/metal/rescue.rb:22:in `process_action'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/actionpack-6.1.4.4/lib/action_controller/metal/instrumentation.rb:34:in `block in process_action'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/activesupport-6.1.4.4/lib/active_support/notifications.rb:203:in `block in instrument'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/activesupport-6.1.4.4/lib/active_support/notifications/instrumenter.rb:24:in `instrument'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/activesupport-6.1.4.4/lib/active_support/notifications.rb:203:in `instrument'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/actionpack-6.1.4.4/lib/action_controller/metal/instrumentation.rb:33:in `process_action'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/actionpack-6.1.4.4/lib/action_controller/metal/params_wrapper.rb:249:in `process_action'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/searchkick-4.5.2/lib/searchkick/logging.rb:212:in `process_action'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/activerecord-6.1.4.4/lib/active_record/railties/controller_runtime.rb:27:in `process_action'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/actionpack-6.1.4.4/lib/abstract_controller/base.rb:165:in `process'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/actionview-6.1.4.4/lib/action_view/rendering.rb:39:in `process'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/actionpack-6.1.4.4/lib/action_controller/metal.rb:190:in `dispatch'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/actionpack-6.1.4.4/lib/action_controller/test_case.rb:580:in `process_controller_response'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/actionpack-6.1.4.4/lib/action_controller/test_case.rb:499:in `process'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/actionpack-6.1.4.4/lib/action_controller/test_case.rb:398:in `get'
        /home/circleci/project/spec/controllers/api/funfun_controller_spec.rb:77:in `block (5 levels) in <top (required)>'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example.rb:262:in `instance_exec'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example.rb:262:in `block in run'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example.rb:508:in `block in with_around_and_singleton_context_hooks'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example.rb:465:in `block in with_around_example_hooks'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/hooks.rb:486:in `block in run'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/hooks.rb:626:in `block in run_around_example_hooks_for'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example.rb:350:in `call'
        /home/circleci/project/spec/controllers/api/funfun_controller_spec.rb:6:in `block (3 levels) in <top (required)>'
        /home/circleci/project/vendor/gems/funny_gem/lib/funny_gem/locale.rb:272:in `around'
        /home/circleci/project/spec/controllers/api/funfun_controller_spec.rb:5:in `block (2 levels) in <top (required)>'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example.rb:455:in `instance_exec'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example.rb:455:in `instance_exec'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/hooks.rb:390:in `execute_with'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/hooks.rb:628:in `block (2 levels) in run_around_example_hooks_for'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example.rb:350:in `call'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-rails-4.0.2/lib/rspec/rails/example/controller_example_group.rb:191:in `block (2 levels) in <module:ControllerExampleGroup>'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example.rb:455:in `instance_exec'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example.rb:455:in `instance_exec'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/hooks.rb:390:in `execute_with'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/hooks.rb:628:in `block (2 levels) in run_around_example_hooks_for'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example.rb:350:in `call'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-rails-4.0.2/lib/rspec/rails/adapters.rb:75:in `block (2 levels) in <module:MinitestLifecycleAdapter>'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example.rb:455:in `instance_exec'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example.rb:455:in `instance_exec'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/hooks.rb:390:in `execute_with'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/hooks.rb:628:in `block (2 levels) in run_around_example_hooks_for'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example.rb:350:in `call'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/webmock-3.14.0/lib/webmock/rspec.rb:37:in `block (2 levels) in <top (required)>'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example.rb:455:in `instance_exec'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example.rb:455:in `instance_exec'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/hooks.rb:390:in `execute_with'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/hooks.rb:628:in `block (2 levels) in run_around_example_hooks_for'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example.rb:350:in `call'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/hooks.rb:629:in `run_around_example_hooks_for'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/hooks.rb:486:in `run'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example.rb:465:in `with_around_example_hooks'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example.rb:508:in `with_around_and_singleton_context_hooks'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example.rb:259:in `run'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example_group.rb:644:in `block in run_examples'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example_group.rb:640:in `map'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example_group.rb:640:in `run_examples'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example_group.rb:606:in `run'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example_group.rb:607:in `block in run'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example_group.rb:607:in `map'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example_group.rb:607:in `run'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example_group.rb:607:in `block in run'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example_group.rb:607:in `map'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example_group.rb:607:in `run'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example_group.rb:607:in `block in run'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example_group.rb:607:in `map'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/example_group.rb:607:in `run'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/runner.rb:121:in `block (3 levels) in run_specs'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/runner.rb:121:in `map'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/runner.rb:121:in `block (2 levels) in run_specs'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/configuration.rb:2067:in `with_suite_hooks'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/runner.rb:116:in `block in run_specs'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/reporter.rb:74:in `report'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/runner.rb:115:in `run_specs'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/runner.rb:89:in `run'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/runner.rb:71:in `run'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/lib/rspec/core/runner.rb:45:in `invoke'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/gems/rspec-core-3.10.1/exe/rspec:4:in `<top (required)>'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/bin/rspec:25:in `load'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/bin/rspec:25:in `<top (required)>'
        /home/circleci/.rubygems/gems/bundler-2.2.30/lib/bundler/cli/exec.rb:58:in `load'
        /home/circleci/.rubygems/gems/bundler-2.2.30/lib/bundler/cli/exec.rb:58:in `kernel_load'
        /home/circleci/.rubygems/gems/bundler-2.2.30/lib/bundler/cli/exec.rb:23:in `run'
        /home/circleci/.rubygems/gems/bundler-2.2.30/lib/bundler/cli.rb:478:in `exec'
        /home/circleci/.rubygems/gems/bundler-2.2.30/lib/bundler/vendor/thor/lib/thor/command.rb:27:in `run'
        /home/circleci/.rubygems/gems/bundler-2.2.30/lib/bundler/vendor/thor/lib/thor/invocation.rb:127:in `invoke_command'
        /home/circleci/.rubygems/gems/bundler-2.2.30/lib/bundler/vendor/thor/lib/thor.rb:392:in `dispatch'
        /home/circleci/.rubygems/gems/bundler-2.2.30/lib/bundler/cli.rb:31:in `dispatch'
        /home/circleci/.rubygems/gems/bundler-2.2.30/lib/bundler/vendor/thor/lib/thor/base.rb:485:in `start'
        /home/circleci/.rubygems/gems/bundler-2.2.30/lib/bundler/cli.rb:25:in `start'
        /home/circleci/.rubygems/gems/bundler-2.2.30/exe/bundle:49:in `block in <top (required)>'
        /home/circleci/.rubygems/gems/bundler-2.2.30/lib/bundler/friendly_errors.rb:103:in `with_friendly_errors'
        /home/circleci/.rubygems/gems/bundler-2.2.30/exe/bundle:37:in `<top (required)>'
        /home/circleci/.rubygems/bin/bundle:25:in `load'
        /home/circleci/.rubygems/bin/bundle:25:in `<main>'
      EOS

      @expected_bt = <<~EOS.chomp.split("\n")
        /home/circleci/project/app/controllers/application_controller.rb:174:in `block (2 levels) in block_fun'
        actionpack (6.1.4.4) lib/action_controller/metal/mime_responds.rb:214:in `respond_to'
        /home/circleci/project/app/controllers/application_controller.rb:170:in `block_fun'
        activesupport (6.1.4.4) lib/active_support/callbacks.rb:427:in `block in make_lambda'
        activesupport (6.1.4.4) lib/active_support/callbacks.rb:198:in `block (2 levels) in halting'
        actionpack (6.1.4.4) lib/abstract_controller/callbacks.rb:34:in `block (2 levels) in <module:Callbacks>'
        activesupport (6.1.4.4) lib/active_support/callbacks.rb:199:in `block in halting'
        activesupport (6.1.4.4) lib/active_support/callbacks.rb:512:in `block in invoke_before'
        activesupport (6.1.4.4) lib/active_support/callbacks.rb:512:in `each'
        activesupport (6.1.4.4) lib/active_support/callbacks.rb:512:in `invoke_before'
        activesupport (6.1.4.4) lib/active_support/callbacks.rb:115:in `block in run_callbacks'
        vanity (ce67b2c66864) lib/vanity/frameworks/rails.rb:141:in `vanity_context_filter'
        activesupport (6.1.4.4) lib/active_support/callbacks.rb:126:in `block in run_callbacks'
        actiontext (6.1.4.4) lib/action_text/rendering.rb:20:in `with_renderer'
        actiontext (6.1.4.4) lib/action_text/engine.rb:59:in `block (4 levels) in <class:Engine>'
        activesupport (6.1.4.4) lib/active_support/callbacks.rb:126:in `instance_exec'
        activesupport (6.1.4.4) lib/active_support/callbacks.rb:126:in `block in run_callbacks'
        react-rails (2.6.1) lib/react/rails/controller_lifecycle.rb:31:in `use_react_component_helper'
        activesupport (6.1.4.4) lib/active_support/callbacks.rb:126:in `block in run_callbacks'
        activesupport (6.1.4.4) lib/active_support/callbacks.rb:137:in `run_callbacks'
        BacktraceCleaner.minimum_first ... and next silenced backtraces
        /home/circleci/project/spec/controllers/api/funfun_controller_spec.rb:77:in `block (5 levels) in <top (required)>'
        /home/circleci/project/spec/controllers/api/funfun_controller_spec.rb:6:in `block (3 levels) in <top (required)>'
        /home/circleci/project/vendor/gems/funny_gem/lib/funny_gem/locale.rb:272:in `around'
        /home/circleci/project/spec/controllers/api/funfun_controller_spec.rb:5:in `block (2 levels) in <top (required)>'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/bin/rspec:25:in `load'
        /home/circleci/project/vendor/bundle/ruby/2.7.0/bin/rspec:25:in `<top (required)>'
        /home/circleci/.rubygems/gems/bundler-2.2.30/lib/bundler/cli/exec.rb:58:in `load'
        /home/circleci/.rubygems/gems/bundler-2.2.30/lib/bundler/cli/exec.rb:58:in `kernel_load'
        /home/circleci/.rubygems/gems/bundler-2.2.30/lib/bundler/cli/exec.rb:23:in `run'
        /home/circleci/.rubygems/gems/bundler-2.2.30/lib/bundler/cli.rb:478:in `exec'
        /home/circleci/.rubygems/gems/bundler-2.2.30/lib/bundler/vendor/thor/lib/thor/command.rb:27:in `run'
        /home/circleci/.rubygems/gems/bundler-2.2.30/lib/bundler/vendor/thor/lib/thor/invocation.rb:127:in `invoke_command'
        /home/circleci/.rubygems/gems/bundler-2.2.30/lib/bundler/vendor/thor/lib/thor.rb:392:in `dispatch'
        /home/circleci/.rubygems/gems/bundler-2.2.30/lib/bundler/cli.rb:31:in `dispatch'
        /home/circleci/.rubygems/gems/bundler-2.2.30/lib/bundler/vendor/thor/lib/thor/base.rb:485:in `start'
        /home/circleci/.rubygems/gems/bundler-2.2.30/lib/bundler/cli.rb:25:in `start'
        /home/circleci/.rubygems/gems/bundler-2.2.30/exe/bundle:49:in `block in <top (required)>'
        /home/circleci/.rubygems/gems/bundler-2.2.30/lib/bundler/friendly_errors.rb:103:in `with_friendly_errors'
        /home/circleci/.rubygems/gems/bundler-2.2.30/exe/bundle:37:in `<top (required)>'
        /home/circleci/.rubygems/bin/bundle:25:in `load'
        /home/circleci/.rubygems/bin/bundle:25:in `<main>'
      EOS
    end

    def test_backtrace
      Gem.stub :path, ['/home/circleci/project/vendor/bundle/ruby/2.7.0'] do
        Gem.stub :default_path, [] do
          cleaner = ActiveSupport::BacktraceCleaner.new
          bt = cleaner.clean(@backtrace)
          assert_equal bt.join("\n"), @expected_bt.join("\n")
        end
      end
    end

    def test_backtrace_with_enumerator
      Gem.stub :path, ['/home/circleci/project/vendor/bundle/ruby/2.7.0'] do
        Gem.stub :default_path, [] do
          cleaner = ActiveSupport::BacktraceCleaner.new
          bt = cleaner.clean(@backtrace.lazy)
          assert_equal bt.join("\n"), @expected_bt.join("\n")
        end
      end
    end

    def test_backtrace_to_keep
      e = ArgumentError.new(m: 'blahasdf', desc: 'qwer')
      new_e = StandardError.new(e)
      assert_equal new_e.message, e.message
      assert_equal new_e.description, e.description
      assert_nil new_e.backtrace
      assert_nil e.backtrace
    end

    def test_backtrace_to_keep_as_cause
      raise ArgumentError, m: 'blahasdf', desc: 'qwer'
    rescue => e
      new_e = StandardError.new(e)
      assert_equal new_e.message, e.message
      assert_equal new_e.description, e.description
      assert_equal new_e.backtrace, e.backtrace
    end

    def sample_method_for_sse
      sample_method_for_sse
    end

    def test_system_stack_error
      sample_method_for_sse
    rescue SystemStackError => e
      new_e = StandardError.new(e)
      assert_equal new_e.backtrace, e.backtrace
    end
  end
end
