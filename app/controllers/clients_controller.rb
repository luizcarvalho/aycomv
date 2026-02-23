class ClientsController < ApplicationController
  before_action :set_client, only: %i[ show edit update destroy ]

  def index
    @pagy, @clients = pagy(Client.alphabetically)
  end

  def show
    @streams = @client.streams.reverse_chronologically
  end

  def new
    @client = Client.new
  end


  def create
    @client = Client.new(client_params)

    if @client.save
      Event.log(modulo: "client", rotulo: "client_created", valor: @client.id, object_id: @client.id, metadata: { name: @client.name })
      redirect_to clients_path, notice: "Cliente cadastrado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end


  def update
    if @client.update(client_params)
      Event.log(modulo: "client", rotulo: "client_updated", valor: @client.id, object_id: @client.id, metadata: { name: @client.name })
      redirect_to clients_path, notice: "Cliente atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    Event.log(modulo: "client", rotulo: "client_destroyed", valor: @client.id, object_id: @client.id, metadata: { name: @client.name })
    @client.destroy!
    redirect_to clients_path, notice: "Cliente removido."
  end

  private
    def set_client
      @client = Client.find(params[:id])
    end

    def client_params
      params.expect(client: [ :name, :email, :notify_on_generate ])
    end
end
