class Meaning < ApplicationRecord
  extend Enumerize

  belongs_to :word

  validates :text, presence: true, uniqueness: true

  enumerize :status, in: [ :erroneous, :successful ], scope: true, predicates: true
end
