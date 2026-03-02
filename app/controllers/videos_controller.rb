class VideosController < ApplicationController
  before_action :set_video, only: :destroy

  def index
    @clients = Client.order(:name)
    @streams = Stream.order(:name)
    @videos = Video.preloaded
    @videos = @videos.for_client_id(params[:client_id]) if params[:client_id].present?
    @videos = @videos.for_stream(params[:stream_id]) if params[:stream_id].present?
    @videos = @videos.by_date(params[:date]) if params[:date].present?
    @videos = @videos.sorted_by(params[:sort])

    @pagy, @videos = pagy(@videos, limit: 12)
  end

  def destroy
    Event.log(modulo: "video", rotulo: "video_destroyed", valor: @video.id, client_id: @video.stream.client_id,
      metadata: { stream_name: @video.stream.name, date: @video.date.to_s })

    if @video.destroy
      redirect_to videos_path, notice: "Vídeo excluído com sucesso."
    else
      redirect_to videos_path, alert: "Erro ao excluir vídeo: #{@video.errors.full_messages.join(', ')}"
    end
  end

  private

  def set_video
    @video = Video.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to videos_path, alert: "Vídeo não encontrado."
  end
end
