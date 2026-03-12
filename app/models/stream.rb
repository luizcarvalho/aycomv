class Stream < ApplicationRecord
  require "fileutils"

  belongs_to :client

  has_many :videos, dependent: :destroy

  after_destroy :delete_generated_assets

  enum :status, { offline: 0, online: 1, starting: 2, error: 3 }

  validates :name, presence: true
  validates :url, presence: true
  validate :capture_window_must_be_complete
  validate :capture_window_must_be_valid

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
    update!(error_message: error_message, last_error_at: Time.current)
  end

  def capture_window_configured?
    capture_start_time.present? && capture_end_time.present?
  end

  def capture_window_label
    return "Dia inteiro" unless capture_window_configured?

    "#{capture_start_time.strftime('%H:%M')} às #{capture_end_time.strftime('%H:%M')}"
  end

  private

  def capture_window_must_be_complete
    return unless capture_start_time.present? ^ capture_end_time.present?

    errors.add(:base, "Preencha o horário inicial e final da captura")
  end

  def capture_window_must_be_valid
    return unless capture_window_configured?
    return if capture_end_time > capture_start_time

    errors.add(:capture_end_time, "deve ser maior que o horário inicial")
  end

  def delete_generated_assets
    FileUtils.rm_rf(frames_directory)
    FileUtils.rm_rf(videos_directory)
    FileUtils.rm_f(preview_file)
  rescue StandardError => e
    Rails.logger.error "Failed to delete generated assets for stream #{id}: #{e.message}"
  end

  def frames_directory
    Rails.root.join("storage", "streams", id.to_s)
  end

  def videos_directory
    Rails.root.join("public", "videos", id.to_s)
  end

  def preview_file
    Rails.root.join("public", "previews", "#{id}.jpg")
  end
end
