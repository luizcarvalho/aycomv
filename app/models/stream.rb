class Stream < ApplicationRecord
  belongs_to :client

  has_many :videos, dependent: :destroy

  enum :status, { offline: 0, online: 1, starting: 2, error: 3 }

  validates :name, presence: true
  validates :url, presence: true

  scope :active, -> { where(status: %i[online starting]) }
  scope :reverse_chronologically, -> { order(created_at: :desc) }
  scope :preloaded, -> { includes(:client) }

  def toggle_status
    online? ? go_offline : go_online
  end

  def go_online
    update!(status: :online, error_message: nil)
  end

  def go_offline
    update!(status: :offline, error_message: "Parado manualmente")
  end
end
