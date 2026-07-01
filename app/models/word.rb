class Word < ApplicationRecord
  has_many :meanings, dependent: :destroy

  validates :text, presence: true, uniqueness: true

  scope :with_pending_meanings, -> {
    joins(:meanings)
      .where(meanings: { status: :pending })
      .distinct
  }
end
