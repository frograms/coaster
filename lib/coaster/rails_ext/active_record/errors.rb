module ActiveRecord
  module RecordMessages
    # user friendly message, for overid
    def user_message
      return _translate if description.present? || tkey.present?
      return record.errors.full_messages.join(', ') if record.present?
      return "#{_translate} (#{user_digests})" unless defined?(@coaster)
      message
    rescue => e
      "#{message} (user_message_error - #{e.class.name} #{e.message})"
    end
  end

  class RecordNotSaved < ActiveRecordError
    include RecordMessages
  end
  class RecordNotDestroyed < ActiveRecordError
    include RecordMessages
  end
  class SoleRecordExceeded < ActiveRecordError
    include RecordMessages
  end
  class StaleObjectError < ActiveRecordError
    include RecordMessages
  end
end
