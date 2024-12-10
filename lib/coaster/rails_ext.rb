require 'coaster/rails_ext/backtrace_cleaner'
ActiveSupport.on_load(:active_record, yield: true) do
  require 'coaster/rails_ext/active_record/errors'
end
