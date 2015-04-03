module ProofHelper
  def proof_timeout_label(value)
    if value >= 1.days
      normalized_value = value / 1.days
      label = t('proofs.new.timeout.day')
      "#{normalized_value} #{label.pluralize(normalized_value)}"
    elsif value >= 1.hours
      normalized_value = value / 1.hours
      label = t('proofs.new.timeout.hour')
      "#{normalized_value} #{label.pluralize(normalized_value)}"
    elsif value >= 1.minutes
      normalized_value = value / 1.minutes
      label = t('proofs.new.timeout.minute')
      "#{normalized_value} #{label.pluralize(normalized_value)}"
    else
      "#{value} #{t('proofs.new.timeout.second').pluralize(value)}"
    end
  end
end
