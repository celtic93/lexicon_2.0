class Meaning < ApplicationRecord
  extend Enumerize

  STATUSES = %i[ duplicate erroneous pending successful ].freeze

  belongs_to :word

  validates :text, presence: true, uniqueness: true

  enumerize :status, in: STATUSES, scope: true, predicates: true
end
