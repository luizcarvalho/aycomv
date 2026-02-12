class VideosController < ApplicationController
  def index
    @clients = Client.order(:name)
    @streams = Stream.order(:name)
    @videos = Video.preloaded.reverse_chronologically
    @videos = @videos.for_client_id(params[:client_id]) if params[:client_id].present?
    @videos = @videos.for_stream(params[:stream_id]) if params[:stream_id].present?
  end

  def destroy
    @video = Video.find(params[:id])
    @video.destroy!
    redirect_to videos_path, notice: "Vídeo excluído."
  end
end
