namespace :streams do
  desc "Capture a snapshot from all active streams"
  task capture: :environment do
    Stream.active.find_each do |stream|
      StreamCaptureService.new(stream).call
    end
  end

  desc "Compile daily video from snapshots"
  task compile: :environment do
    # Allow passing a specific date, default to yesterday (since we compile the full previous day)
    # Usage: rake streams:compile date=2023-10-27
    # Usage: rake streams:compile stream_id=42
    # Usage: rake streams:compile stream_id=42 date=2023-10-27
    date_str = ENV["date"] || Date.yesterday.to_s
    date = Date.parse(date_str)

    puts "Compiling videos for #{date}..."

    streams = if ENV["stream_id"].present?
      Stream.where(id: ENV["stream_id"])
    else
      Stream.active
    end

    streams.find_each do |stream|
      StreamCompilerService.new(stream, date).call
    end
  end
end
