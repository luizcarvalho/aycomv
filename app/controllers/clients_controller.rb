class ClientsController < ApplicationController
  before_action :set_client, only: %i[ show edit update destroy ]

  def index
    @clients = Client.alphabetically.all
  end

  def show
    @streams = @client.streams.reverse_chronologically
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.create!(client_params)
    redirect_to clients_path, notice: "Cliente cadastrado com sucesso!"
  end

  def edit
  end

  def update
    @client.update!(client_params)
    redirect_to clients_path, notice: "Cliente atualizado com sucesso!"
  end

  def destroy
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
