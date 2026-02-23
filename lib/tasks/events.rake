namespace :events do
  desc "Build mock Events registers for development"
  task seed: :environment do
    puts "Seeding mock events..."

    modules = [ "stream", "video", "client", "notification" ]
    labels = {
      "stream" => [ "Capture Success", "Capture Error", "Stream Started", "Stream Stopped" ],
      "video" => [ "Compilation Started", "Compilation Finished", "Compilation Error", "Thumbnail Updated" ],
      "client" => [ "Client Created", "Client Updated", "Auth Failure" ],
      "notification" => [ "Email Sent", "Worker Started", "Worker Finished" ]
    }

    clients = Client.all.to_a
    count = ENV["count"]&.to_i || 100

    count.times do |i|
      modulo = modules.sample
      rotulo = labels[modulo].sample
      client = clients.sample if rand < 0.7 && clients.any?

      created_at = rand(0..10).days.ago - rand(0..23).hours - rand(0..59).minutes

      Event.create!(
        modulo: modulo,
        rotulo: rotulo,
        valor: "Mock value #{rand(1000..9999)}",
        client_id: client&.id,
        metadata: {
          ip: "127.0.0.1",
          user_agent: "MockAgent/1.0",
          item_index: i,
          random_hex: SecureRandom.hex(4)
        },
        created_at: created_at
      )
    end

    puts "Successfully created #{count} mock events."
  end
end
