class Client < ApplicationRecord
  has_many :streams, dependent: :destroy
  has_many :videos, through: :streams

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  normalizes :email, with: ->(email) { email.strip.downcase }

  scope :alphabetically, -> { order(name: :asc) }
  scope :reverse_chronologically, -> { order(created_at: :desc) }
end
