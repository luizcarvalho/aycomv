class StreamCaptureService
  require "open3"
  require "fileutils"

  def initialize(stream)
    @stream = stream
  end

  def call
    prepare_directory
    capture_snapshot
  rescue => e
    handle_error(e.message)
  end

  private

  attr_reader :stream

  def prepare_directory
    FileUtils.mkdir_p(directory)
  end

  def directory
    @directory ||= Rails.root.join("storage", "streams", stream.id.to_s, Date.today.to_s)
  end

  def filepath
    @filepath ||= directory.join("#{Time.now.strftime('%H%M%S')}.jpg")
  end

  def capture_snapshot
    # Capture frame using ffmpeg
    # -y: overwrite output files
    # -rw_timeout 10000000: 10s timeout for TCP reads (microseconds)
    # -loglevel error: suppress verbose output
    # -i: input url
    # -vframes 1: output one frame
    # -q:v 2: high quality jpeg
    cmd = "ffmpeg -y -rw_timeout 10000000 -loglevel error -i \"#{stream.url}\" -vframes 1 -q:v 2 \"#{filepath}\""
    stdout, stderr, status = Open3.capture3(cmd)

    if status.success? && File.exist?(filepath)
      handle_success(filepath)
    else
      handle_failure(stdout, stderr)
    end
  end

  def handle_success(path)
    Rails.logger.info "Captured snapshot for stream #{stream.id}: #{path}"

    stream.frames_count += 1
    stream.last_frame_at = Time.current
    stream.save!

    update_preview(path)
  end

  def handle_failure(stdout, stderr)
    Rails.logger.warn "Failed to capture snapshot for stream #{stream.id}"
    Rails.logger.warn "FFmpeg Error: #{stderr}"

    error_message = "Failed to capture snapshot. Error: #{stderr.strip}"
    # Truncate error message to fit in database if necessary
    stream.update(error_message: error_message.truncate(255))
  end

  def handle_error(message)
    error_msg = "Error capturing stream #{stream.id}: #{message}"
    Rails.logger.error error_msg
    stream.update(error_message: error_msg)
  end

  def update_preview(source_path)
    # Update preview (Rate limit: 2 minutes)
    preview_dir = Rails.root.join("public", "previews")
    FileUtils.mkdir_p(preview_dir)
    preview_path = preview_dir.join("#{stream.id}.jpg")

    if !File.exist?(preview_path) || (Time.now - File.mtime(preview_path) > 120)
      FileUtils.cp(source_path, preview_path)
      stream.update(
        preview_url: "/previews/#{stream.id}.jpg?t=#{Time.now.to_i}",
        error_message: nil
      )
      puts "Updated preview for stream #{stream.id}"
    elsif stream.error_message.present?
      # Clear error message if capture was successful but we skipped preview update
      stream.update(error_message: nil)
    end
  end
end
