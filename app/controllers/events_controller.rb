class EventsController < ApplicationController
  def index
    @events = Event.includes(:client).reverse_chronologically
    @events = @events.by_modulo(params[:modulo]) if params[:modulo].present?
    @events = @events.by_rotulo(params[:rotulo]) if params[:rotulo].present?
    @events = @events.by_valor(params[:valor]) if params[:valor].present?
    @events = @events.by_client(params[:client_id]) if params[:client_id].present?
    @events = @events.by_date_range(params[:date_from], params[:date_to]) if params[:date_from].present? || params[:date_to].present?

    @pagy, @events = pagy(@events, limit: 50)
  end
end
