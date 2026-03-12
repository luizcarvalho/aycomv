class StreamCompilerService
  require "securerandom"
  require "fileutils"
  require "tmpdir"

  def initialize(stream, date)
    @stream = stream
    @date = date
  end

  def call
    return unless input_directory_exists?
    return unless enough_images?

    compile_video
  rescue => e
    handle_error(e.message)
  end

  private

  attr_reader :stream, :date

  # Create Events for No images and Not enough images
  def input_directory
    @input_directory ||= Rails.root.join("storage", "streams", stream.id.to_s, date.to_s)
  end

  def input_directory_exists?
    unless Dir.exist?(input_directory)
      puts "No images found for stream #{stream.id} on #{date}"
      Event.log(modulo: "video", rotulo: "compilation_error", valor: stream.id, client_id: stream.client_id, metadata: { error: "No images found for stream #{stream.id} on #{date}" })
      return false
    end
    true
  end

  def enough_images?
    count = image_count
    if count < 10
      puts "Not enough images (#{count}) for stream #{stream.id}"
      Event.log(modulo: "video", rotulo: "compilation_error", valor: stream.id, client_id: stream.client_id, metadata: { error: "Not enough images (#{count}) for stream #{stream.id}" })
      return false
    end
    true
  end

  def image_count
    @image_count ||= selected_images.count
  end

  def output_dir
    @output_dir ||= Rails.root.join("public", "videos", stream.id.to_s)
  end

  def output_filename
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    @output_filename ||= "#{timestamp}_#{SecureRandom.uuid}.mp4"
  end

  def output_path
    @output_path ||= output_dir.join(output_filename)
  end

  def compile_video
    ensure_output_directory_exists

    puts "Compiling #{image_count} images for stream #{stream.id}..."
    Dir.mktmpdir(["stream-compile-", stream.id.to_s], Rails.root.join("tmp")) do |compile_directory|
      prepare_compile_directory(compile_directory)

      # FFmpeg command to stitch images
      # -start_number 0: use the generated sequential input list
      # -framerate 30: 30 fps
      # -c:v libx264: H.264 codec (universal browser support, unlike H.265)
      # -crf 28: Constant Rate Factor (good quality with small file size)
      # -preset slow: Better compression ratio (slower encoding, smaller files)
      # -profile:v high -level 4.0: Maximum compatibility across browsers/devices
      # -pix_fmt yuv420p: Ensure compatibility with all players
      # -movflags +faststart: Move moov atom to start for progressive browser playback
      @ffmpeg_cmd = "ffmpeg -y -framerate 30 -start_number 0 -i \"#{compile_directory}/%06d.jpg\" -c:v libx264 -crf 28 -preset slow -profile:v high -level 4.0 -pix_fmt yuv420p -movflags +faststart \"#{output_path}\" > /dev/null 2>&1"
      success = system(@ffmpeg_cmd)

      if success && File.exist?(output_path)
        generate_thumbnail
        create_video_record
        puts "Successfully created video: #{output_path}"
      else
        handle_failure
      end
    end
  end

  def ensure_output_directory_exists
    FileUtils.mkdir_p(output_dir)
  end

  def thumbnail_filename
    @thumbnail_filename ||= output_filename.sub(".mp4", ".jpg")
  end

  def thumbnail_path
    @thumbnail_path ||= output_dir.join(thumbnail_filename)
  end

  def generate_thumbnail
    puts "Generating thumbnail for stream #{stream.id}"
    seek_time = [ (image_count / 30) / 2, 1 ].max
    cmd = "ffmpeg -y -ss #{seek_time} -i \"#{output_path}\" -frames:v 1 -q:v 2 \"#{thumbnail_path}\" > /dev/null 2>&1"
    system(cmd)
  end

  def create_video_record
    video = Video.create!(
      stream: stream,
      date: date,
      created_at: Time.now,
      file_path: "/videos/#{stream.id}/#{output_filename}",
      thumbnail_url: File.exist?(thumbnail_path) ? "/videos/#{stream.id}/#{thumbnail_filename}" : nil,
      duration: image_count / 30,
      generated_at: Time.now
    )
    zero_frame = stream.update!(frames_count: 0)

    Event.log(modulo: "video", rotulo: "video_created", valor: stream.id, client_id: stream.client_id,
      metadata: { stream_name: stream.name, frames: image_count, duration: video.duration, zero_frame: zero_frame, ffmpeg_cmd: @ffmpeg_cmd })

    # Só envia e-mail se o cliente quiser ser notificado
    if stream.client.notify_on_generate?
      send_mail(video)
    end
  end

  def send_mail(video)
    video.client.notification_emails.each do |recipient|
      VideoMailer.with(video: video, recipient: recipient).notification_email.deliver_now
    rescue StandardError => e
      Rails.logger.error "Failed to send email for video #{video.id} to #{recipient}: #{e.message}"
      Event.log(modulo: "notification", rotulo: "email_failure", valor: video.id, client_id: video.stream.client_id,
        metadata: { error: e.message, to: recipient })
    end
  end

  def handle_failure
    message = "FFmpeg failed for stream #{stream.id}"
    puts message
    stream.update(error_message: message)

    Event.log(modulo: "video", rotulo: "compilation_failure", valor: stream.id, client_id: stream.client_id, metadata: { error: message })
  end

  def handle_error(message)
    error_msg = "Error compiling stream #{stream.id}: #{message}"
    puts error_msg
    stream.update(error_message: error_msg)

    Event.log(modulo: "video", rotulo: "compilation_error", valor: stream.id, client_id: stream.client_id, metadata: { error: error_msg })
  end

  def selected_images
    @selected_images ||= begin
      images = Dir[input_directory.join("*.jpg")].sort
      if !stream.capture_window_configured?
        images
      else
        images.select do |image_path|
          frame_time = extract_frame_time(image_path)
          frame_time.present? && frame_time.between?(capture_start_key, capture_end_key)
        end
      end
    end
  end

  def prepare_compile_directory(compile_directory)
    selected_images.each_with_index do |image_path, index|
      FileUtils.ln_sf(image_path, File.join(compile_directory, format("%06d.jpg", index)))
    end
  end

  def extract_frame_time(image_path)
    basename = File.basename(image_path, ".jpg")
    return basename if basename.match?(/\A\d{6}\z/)

    nil
  end

  def capture_start_key
    @capture_start_key ||= stream.capture_start_time.strftime("%H%M%S")
  end

  def capture_end_key
    @capture_end_key ||= stream.capture_end_time.strftime("%H%M%S")
  end
end
