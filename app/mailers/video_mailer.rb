class VideoMailer < ApplicationMailer
  def notification_email
    @video = params[:video]
    @client = @video.stream.client
    @download_url = "http://localhost:3000#{@video.file_path}" # TODO: Configure host properly for production

    Rails.logger.info("Sending email to #{@client.email}")
    mail(to: @client.email, subject: "Seu vídeo foi processado com sucesso! 🎥") do |format|
      format.html { render layout: false }
    end

    Event.log(modulo: "notification", rotulo: "email_sent", valor: @video.id, client_id: @client.id,
      metadata: { to: @client.email, subject: "Seu vídeo foi processado com sucesso! 🎥" })
  end
end
