require "test_helper"

class StreamCaptureServiceTest < ActiveSupport::TestCase
  setup do
    @stream = streams(:one)
  end

  test "builds an optimized ffmpeg command for snapshots" do
    service = StreamCaptureService.new(@stream)
    command = service.send(:ffmpeg_command)

    assert_equal "ffmpeg", command.first
    assert_includes command.each_cons(2).to_a, ["-map_metadata", "-1"]
    assert_includes command.each_cons(2).to_a, ["-pix_fmt", "yuvj420p"]
    assert_includes command.each_cons(2).to_a, ["-q:v", "2"]
    assert_equal service.send(:filepath).to_s, command.last
  end
end
