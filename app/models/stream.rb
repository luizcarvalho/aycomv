class Stream < ApplicationRecord
  belongs_to :client

  has_many :videos, dependent: :destroy

  enum :status, { offline: 0, online: 1, starting: 2, error: 3 }

  validates :name, presence: true
  validates :url, presence: true

  scope :active, -> { where(status: %i[online starting]) }
  scope :reverse_chronologically, -> { order(created_at: :desc) }
  scope :preloaded, -> { includes(:client) }
  scope :for_client, ->(client_id) { where(client_id: client_id) }

  def toggle_status
    online? ? go_offline : go_online
  end

  def go_online
    update!(status: :online, error_message: nil)
  end

  def go_offline(error_message: "Parado manualmente")
    update!(status: :offline, error_message: error_message)
  end

  def go_error(error_message:)
    update!(status: :error, error_message: error_message, last_error_at: Time.current)
  end
end
