require "test_helper"

class StreamTest < ActiveSupport::TestCase
  test "requires complete capture window" do
    stream = Stream.new(name: "Camera", url: "rtsp://example.com/live", client: clients(:one), capture_start_time: "06:00")

    assert_not stream.valid?
    assert_includes stream.errors[:base], "Preencha o horário inicial e final da captura"
  end

  test "deletes generated assets when stream is destroyed" do
    stream = Stream.create!(name: "Cleanup", url: "rtsp://example.com/cleanup", client: clients(:one))
    frames_dir = Rails.root.join("storage", "streams", stream.id.to_s, Date.current.to_s)
    videos_dir = Rails.root.join("public", "videos", stream.id.to_s)
    preview_file = Rails.root.join("public", "previews", "#{stream.id}.jpg")

    FileUtils.mkdir_p(frames_dir)
    FileUtils.mkdir_p(videos_dir)
    FileUtils.touch(frames_dir.join("120000.jpg"))
    FileUtils.touch(videos_dir.join("video.mp4"))
    FileUtils.touch(preview_file)

    stream.destroy!

    assert_not Dir.exist?(Rails.root.join("storage", "streams", stream.id.to_s))
    assert_not Dir.exist?(videos_dir)
    assert_not File.exist?(preview_file)
  end
end
