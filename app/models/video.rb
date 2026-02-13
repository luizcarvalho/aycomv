class Video < ApplicationRecord
  belongs_to :stream

  delegate :client, to: :stream
  delegate :name, to: :stream, prefix: true

  validates :date, presence: true

  scope :reverse_chronologically, -> { order(generated_at: :desc) }
  scope :for_client, ->(client) { joins(:stream).where(streams: { client_id: client.id }) }
  scope :for_client_id, ->(client_id) { joins(:stream).where(streams: { client_id: client_id }) }
  scope :for_stream, ->(stream_id) { where(stream_id: stream_id) }
  scope :preloaded, -> { includes(stream: :client) }
  scope :by_date, ->(date) { where(date: date) }

  def self.sorted_by(sort_option)
    case sort_option
    when "oldest"
      order(generated_at: :asc)
    when "shortest"
      order(duration: :asc)
    when "longest"
      order(duration: :desc)
    else
      order(generated_at: :desc)
    end
  end
end
