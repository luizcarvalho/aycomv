# Seed data matching docs/constants.ts mock data

puts "Seeding admin user..."
admin_email = ENV.fetch("ADMIN_EMAIL", "admin@aycom.com.br")
admin_password = ENV.fetch("ADMIN_PASSWORD", "mocya@123")
User.find_or_create_by!(email_address: admin_email) do |u|
  u.password = admin_password
  u.password_confirmation = admin_password
end
puts "Admin user: #{admin_email}"

# puts "Seeding clients..."

# DEFAULT_MAIL= 'maximusmano@gmail.com'

# ferragista = Client.find_or_create_by!(email: "ferragistasanta+#{DEFAULT_MAIL}") do |c|
#   c.name = "FERRAGISTA SANTA"
#   c.notify_on_generate = true
# end

# dr_amigo = Client.find_or_create_by!(email: "dramigo+#{DEFAULT_MAIL}") do |c|
#   c.name = "DR AMIGO"
#   c.notify_on_generate = true
# end

# armazem = Client.find_or_create_by!(email: "armazemparaiba+#{DEFAULT_MAIL}") do |c|
#   c.name = "ARMAZEM PARAIBA"
#   c.notify_on_generate = true
# end

# record = Client.find_or_create_by!(email: "record+#{DEFAULT_MAIL}") do |c|
#   c.name = "Record"
#   c.notify_on_generate = true
# end

# puts "Seeding streams..."

# # FERRAGISTA SANTA
# Stream.find_or_create_by!(name: "TORRE MAT.- CONSTRUÇÃO", client: ferragista) do |s|
#   s.url = "rtmp://connect-827.servicestream.io:1939/stream/30a8b5d5fc0d"
#   s.status = :online
# end

# Stream.find_or_create_by!(name: "FERRAGISTA SANTA FÉ-B TAQUARALTO T15", client: ferragista) do |s|
#   s.url = "rtmp://connect-827.servicestream.io:1936/stream/2658b1bdaff5"
#   s.status = :online
# end

# # DR AMIGO
# Stream.find_or_create_by!(name: "Dr. Amigo Taquaralto_B", client: dr_amigo) do |s|
#   s.url = "rtmp://connect-827.servicestream.io:1936/stream/2b19bd1a9c1c"
#   s.status = :online
# end

# Stream.find_or_create_by!(name: "Dr. Amigo JK_A", client: dr_amigo) do |s|
#   s.url = "rtmp://connect-827.servicestream.io:1940/stream/5a1b3832d0fa"
#   s.status = :online
# end

# # ARMAZEM PARAIBA
# Stream.find_or_create_by!(name: "ARMAZEM PARAIBA - TAQUARALTO", client: armazem) do |s|
#   s.url = "rtmp://connect-827.servicestream.io:1940/stream/b6227a94e2bc"
#   s.status = :online
# end

# # Record
# Stream.find_or_create_by!(name: "Torre Lago", client: record) do |s|
#   s.url = "rtmp://connect-827.servicestream.io:1938/stream/228ab60abd97"
#   s.status = :online
# end

# puts "Done! Created #{Client.count} clients, #{Stream.count} streams."
