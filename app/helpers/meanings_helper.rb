module MeaningsHelper
  def meaning_card_status_class(meaning)
    warning_statuses = %w[pending erroneous]

    if warning_statuses.include?(meaning.status)
      "meaning-card--warning"
    else
      "meaning-card--success"
    end
  end
end
