class StreamsController < ApplicationController
  before_action :set_stream, only: %i[ show edit update destroy ]

  def index
    @streams = Stream.preloaded.reverse_chronologically
    @streams = @streams.for_client(params[:client_id]) if params[:client_id].present?

    @pagy, @streams = pagy(@streams)
  end

  def show
  end

  def new
    @stream = Stream.new
    @clients = Client.alphabetically
  end

  def create
    @stream = Stream.new(stream_params)
    @clients = Client.alphabetically

    if @stream.save
      Event.log(modulo: "stream", rotulo: "stream_created", valor: @stream.id, client_id: @stream.client_id, metadata: { name: @stream.name })
      redirect_to streams_path, notice: "Stream adicionado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @clients = Client.alphabetically
  end

  def update
    @clients = Client.alphabetically

    if @stream.update(stream_params)
      Event.log(modulo: "stream", rotulo: "stream_updated", valor: @stream.id, client_id: @stream.client_id, metadata: { name: @stream.name })
      redirect_to streams_path, notice: "Alterações salvas com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    Event.log(modulo: "stream", rotulo: "stream_destroyed", valor: @stream.id, client_id: @stream.client_id, metadata: { name: @stream.name })
    @stream.destroy!
    redirect_to streams_path, notice: "Stream excluído."
  end

  private
    def set_stream
      @stream = Stream.find(params[:id])
    end

    def stream_params
      params.expect(stream: [ :name, :url, :client_id, :capture_start_time, :capture_end_time ])
    end
end
