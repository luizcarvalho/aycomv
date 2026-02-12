class VideosController < ApplicationController
  def index
    @videos = Video.preloaded.reverse_chronologically
  end

  def destroy
    @video = Video.find(params[:id])
    @video.destroy!
    redirect_to videos_path, notice: "Vídeo excluído."
  end
end
