class VideoMailer < ApplicationMailer
  def notification_email
    @video = params[:video]
    @client = @video.stream.client
    @recipient = params[:recipient] || @client.primary_email
    @download_url = "https://aycom.com.br/#{@video.file_path}" # TODO: Configure host properly for production

    Rails.logger.info("Sending email to #{@recipient}")
    mail(to: @recipient, subject: "Seu vídeo foi processado com sucesso! 🎥") do |format|
      format.html { render layout: false }
    end

    Event.log(modulo: "notification", rotulo: "email_sent", valor: @video.id, client_id: @client.id,
      metadata: { to: @recipient, subject: "Seu vídeo foi processado com sucesso! 🎥" })
  end
end
