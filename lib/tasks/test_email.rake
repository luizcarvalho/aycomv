namespace :email do
  desc "Send a test email to maximusmano@gmail.com"
  task test: :environment do
    puts "Sending test email to maximusmano@gmail.com..."
    @download_url = ENV["HOST_URL"]

    TestMailer = Class.new(ApplicationMailer) do
      def test_email(download_url)
        mail(
          to: "maximusmano@gmail.com",
          subject: "Teste de envio de e-mail - AycomV 🎥"
        ) do |format|
          format.text do
            render plain: "Este é um e-mail de teste enviado em #{Time.current.strftime('%d/%m/%Y %H:%M:%S')}.\n\nSe você está lendo esta mensagem, o envio de e-mail está funcionando corretamente! ✅\n\nDownload URL: #{download_url}"
          end
        end
      end
    end

    TestMailer.test_email(@download_url).deliver_now

    puts "✅ Test email sent successfully!"
  rescue StandardError => e
    puts "❌ Failed to send test email: #{e.message}"
    puts e.backtrace.first(5).join("\n")
  end
end
