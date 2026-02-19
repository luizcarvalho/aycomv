class VideosController < ApplicationController
  def index
    @clients = Client.order(:name)
    @streams = Stream.order(:name)
    @videos = Video.preloaded
    @videos = @videos.for_client_id(params[:client_id]) if params[:client_id].present?
    @videos = @videos.for_stream(params[:stream_id]) if params[:stream_id].present?
    @videos = @videos.by_date(params[:date]) if params[:date].present?
    @videos = @videos.sorted_by(params[:sort])

    @pagy, @videos = pagy(@videos)
  end

  def destroy
    @video = Video.find(params[:id])
    @video.destroy!
    redirect_to videos_path, notice: "Vídeo excluído."
  end
end
