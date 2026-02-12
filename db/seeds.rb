# Seed data matching docs/constants.ts mock data

puts "Seeding clients..."

horizonte = Client.find_or_create_by!(email: "contato@horizonte.com.br") do |c|
  c.name = "Construtora Horizonte"
  c.notify_on_generate = true
end

energisa = Client.find_or_create_by!(email: "ops@energisa.com.br") do |c|
  c.name = "Energisa Monitoramento"
  c.notify_on_generate = true
end

puts "Seeding streams..."

stream1 = Stream.find_or_create_by!(name: "Camera Torre", client: horizonte) do |s|
  s.url = "rtmp://stream01.example.com/live/torre"
  s.status = :online
  s.preview_url = "https://picsum.photos/400/225?random=1"
end

stream2 = Stream.find_or_create_by!(name: "Camera Energisa", client: energisa) do |s|
  s.url = "rtmp://stream02.example.com/live/energisa"
  s.status = :online
  s.preview_url = "https://picsum.photos/400/225?random=2"
end

stream3 = Stream.find_or_create_by!(name: "Camera Energisa 2", client: energisa) do |s|
  s.url = "rtmp://stream03.example.com/live/energisa2"
  s.status = :offline
  s.error_message = "Falha na conexão - Tentando (Tentativa 3/10)"
end

stream4 = Stream.find_or_create_by!(name: "Camera Obra 51", client: horizonte) do |s|
  s.url = "rtmp://stream04.example.com/live/obra51"
  s.status = :online
  s.preview_url = "https://picsum.photos/400/225?random=3"
end

puts "Seeding videos..."

Video.find_or_create_by!(stream: stream1, date: "2026-02-08") do |v|
  v.generated_at = "2026-02-08T23:59:00Z"
  v.duration = 84
  v.file_path = "/videos/stream-001/timelapse_20260208.mp4"
  v.thumbnail_url = "https://picsum.photos/400/225?random=4"
  v.share_link = "https://aycom.videos/share/v/xyz123"
end

Video.find_or_create_by!(stream: stream2, date: "2026-02-08") do |v|
  v.generated_at = "2026-02-08T23:59:00Z"
  v.duration = 82
  v.file_path = "/videos/stream-002/timelapse_20260208.mp4"
  v.thumbnail_url = "https://picsum.photos/400/225?random=5"
  v.share_link = "https://aycom.videos/share/v/abc987"
end

Video.find_or_create_by!(stream: stream3, date: "2026-02-07") do |v|
  v.generated_at = "2026-02-07T23:59:00Z"
  v.duration = 45
  v.file_path = "/videos/stream-003/timelapse_20260207.mp4"
  v.thumbnail_url = "https://picsum.photos/400/225?random=6"
  v.share_link = "https://aycom.videos/share/v/def456"
  v.note = "Dia parcial - stream teve problemas de conexão"
end

puts "Done! Created #{Client.count} clients, #{Stream.count} streams, #{Video.count} videos."
