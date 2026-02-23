class Event < ApplicationRecord
  validates :modulo, presence: true
  validates :rotulo, presence: true

  scope :by_modulo, ->(modulo) { where(modulo: modulo) }
  scope :by_rotulo, ->(rotulo) { where("rotulo ILIKE ?", "%#{rotulo}%") }
  scope :by_valor, ->(valor) { where("valor ILIKE ?", "%#{valor}%") }
  scope :by_object, ->(object_id) { where(object_id: object_id) }
  scope :by_date_range, ->(from, to) {
    scope = all
    scope = scope.where("created_at >= ?", from.to_date.beginning_of_day) if from.present?
    scope = scope.where("created_at <= ?", to.to_date.end_of_day) if to.present?
    scope
  }
  scope :reverse_chronologically, -> { order(created_at: :desc) }

  def self.log(modulo:, rotulo:, valor: nil, object_id: nil, metadata: {})
    create!(modulo: modulo, rotulo: rotulo, valor: valor.to_s, object_id: object_id, metadata: metadata)
  rescue => e
    Rails.logger.error "Failed to create event: #{e.message}"
  end
end
