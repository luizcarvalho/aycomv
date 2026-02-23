module Streams
  class StatusTogglesController < ApplicationController
    def create
      @stream = Stream.find(params[:stream_id])
      @stream.toggle_status

      Event.log(modulo: "stream", rotulo: "status_toggled", valor: @stream.id, client_id: @stream.client_id,
        metadata: { new_status: @stream.status, name: @stream.name })

      redirect_to streams_path, notice: "Status do stream atualizado."
    end
  end
end
