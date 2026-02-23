class EventsController < ApplicationController
  def index
    @events = Event.reverse_chronologically
    @events = @events.by_modulo(params[:modulo]) if params[:modulo].present?
    @events = @events.by_object(params[:object_id]) if params[:object_id].present?

    @pagy, @events = pagy(@events, limit: 50)
  end
end
