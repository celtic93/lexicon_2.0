class Word < ApplicationRecord
  has_many :meanings

  validates :text, presence: true, uniqueness: true
end
