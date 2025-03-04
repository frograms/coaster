require 'coaster/rails_ext/active_support/backtrace_cleaner'
ActiveSupport.on_load(:active_record, yield: true) do
  require 'coaster/rails_ext/active_record/errors'
end
ActiveSupport.on_load(:action_view, yield: true) do
  require "coaster/rails_ext/action_view/template/error"
end
