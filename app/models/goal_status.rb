class GoalStatus < ActiveRecord::Base
  class FailureReasonValidator < ActiveModel::Validator
    def validate(record)
      if record.status == 'failed'
        if record.failure_reason.blank?
          record.errors[:failure_reason] =
            I18n.t('goal_status.errors.failure_reason_missing')
        end
      else
        if record.failure_reason.present?
          record.errors[:failure_reason] =
            I18n.t('goal_status.errors.failure_reason_present')
        end
      end
    end
  end

  STATUSES = %w(open failed inconsistent disproven proven)

  belongs_to :proof_status

  attr_accessible :status, :failure_reason

  validates_inclusion_of :status, in: STATUSES

  validates_with FailureReasonValidator

  STATUSES.each do |status|
    define_method "#{status}?" do
      @status == status
    end
  end
end
