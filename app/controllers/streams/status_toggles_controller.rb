module Streams
  class StatusTogglesController < ApplicationController
    def create
      @stream = Stream.find(params[:stream_id])
      @stream.toggle_status

      redirect_to streams_path, notice: "Status do stream atualizado."
    end
  end
end
