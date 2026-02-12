class Video < ApplicationRecord
  belongs_to :stream

  delegate :client, to: :stream
  delegate :name, to: :stream, prefix: true

  validates :date, presence: true

  scope :reverse_chronologically, -> { order(generated_at: :desc) }
  scope :for_client, ->(client) { joins(:stream).where(streams: { client_id: client.id }) }
  scope :preloaded, -> { includes(stream: :client) }
end
