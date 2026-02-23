class Event < ApplicationRecord
  validates :modulo, presence: true
  validates :rotulo, presence: true

  scope :by_modulo, ->(modulo) { where(modulo: modulo) }
  scope :by_valor, ->(valor) { where(valor: valor.to_s) }
  scope :by_object, ->(object_id) { where(object_id: object_id) }
  scope :reverse_chronologically, -> { order(created_at: :desc) }

  def self.log(modulo:, rotulo:, valor: nil, object_id: nil, metadata: {})
    create!(modulo: modulo, rotulo: rotulo, valor: valor.to_s, object_id: object_id, metadata: metadata)
  rescue => e
    Rails.logger.error "Failed to create event: #{e.message}"
  end
end
