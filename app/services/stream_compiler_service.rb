class StreamCompilerService
  require "securerandom"
  require "fileutils"

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
    @image_count ||= Dir[input_directory.join("*.jpg")].count
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

    # FFmpeg command to stitch images
    # -pattern_type glob: use glob pattern for input
    # -framerate 30: 30 fps
    # -c:v libx264: H.264 codec
    # -pix_fmt yuv420p: Ensure compatibility with all players
    cmd = "ffmpeg -y -framerate 30 -pattern_type glob -i \"#{input_directory}/*.jpg\" -c:v libx264 -pix_fmt yuv420p \"#{output_path}\" > /dev/null 2>&1"

    success = system(cmd)

    if success && File.exist?(output_path)
      create_video_record
      puts "Successfully created video: #{output_path}"
    else
      handle_failure
    end
  end

  def ensure_output_directory_exists
    FileUtils.mkdir_p(output_dir)
  end

  def create_video_record
    video = Video.create!(
      stream: stream,
      date: date,
      created_at: Time.now,
      file_path: "/videos/#{stream.id}/#{output_filename}", # Relative path for public access
      duration: image_count / 30, # Approx duration
      generated_at: Time.now
    )
    stream.update!(frames_count: 0)

    Event.log(modulo: "video", rotulo: "video_created", valor: stream.id, client_id: stream.client_id,
      metadata: { stream_name: stream.name, frames: image_count, duration: video.duration })

    # Send notification email now
    VideoMailer.with(video: video).notification_email.deliver_now
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
end
