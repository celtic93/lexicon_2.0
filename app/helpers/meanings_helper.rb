module MeaningsHelper
  ACTIONABLE_STATUSES = %w[pending erroneous].freeze

  def meaning_card_status_class(status)
    if ACTIONABLE_STATUSES.include?(status)
      "meaning-card--warning"
    else
      "meaning-card--success"
    end
  end

  def status_actionable?(status)
    ACTIONABLE_STATUSES.include?(status)
  end
end
