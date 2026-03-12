class Client < ApplicationRecord
  EMAIL_FORMAT = URI::MailTo::EMAIL_REGEXP

  has_many :streams, dependent: :destroy
  has_many :videos, through: :streams
  has_many :events, dependent: :nullify

  validates :name, presence: true
  validate :email_list_must_be_present
  validate :email_list_must_be_valid

  normalizes :email, with: ->(value) { Client.normalize_email_list(value) }

  scope :alphabetically, -> { order(name: :asc) }
  scope :reverse_chronologically, -> { order(created_at: :desc) }

  def notification_emails
    self.class.parse_email_list(email)
  end

  def primary_email
    notification_emails.first
  end

  def self.parse_email_list(value)
    value.to_s.split(",").filter_map do |item|
      normalized = item.strip.downcase
      normalized if normalized.present?
    end
  end

  def self.normalize_email_list(value)
    parse_email_list(value).join(", ")
  end

  private

  def email_list_must_be_present
    errors.add(:email, "deve ter pelo menos um endereço") if notification_emails.empty?
  end

  def email_list_must_be_valid
    invalid_emails = notification_emails.reject { |item| item.match?(EMAIL_FORMAT) }
    return if invalid_emails.empty?

    errors.add(:email, "contém endereço(s) inválido(s): #{invalid_emails.join(', ')}")
  end
end
