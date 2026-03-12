require "test_helper"
require "minitest/mock"

class StreamCompilerServiceTest < ActiveSupport::TestCase
  setup do
    @stream = streams(:one)
    @stream.update!(frames_count: 100)
    # Using Yesterday to avoid today's folder issues if any
    @date = Date.yesterday
  end

  test "create_video_record resets frames count" do
    service = StreamCompilerService.new(@stream, @date)

    # Stub private methods to isolate logic
    service.stub :image_count, 300 do
      service.stub :output_filename, "test.mp4" do
        assert_difference "Video.count", 1 do
          assert_changes -> { @stream.reload.frames_count }, from: 100, to: 0 do
            service.send(:create_video_record)
          end
        end

        video = Video.last
        assert_equal @stream, video.stream
        assert_equal @date, video.date
        assert_equal 10, video.duration # 300 / 30
      end
    end
  end

  test "filters frames using stream capture window" do
    @stream.update!(capture_start_time: "06:00", capture_end_time: "18:00")
    input_directory = Rails.root.join("storage", "streams", @stream.id.to_s, @date.to_s)
    FileUtils.mkdir_p(input_directory)

    %w[055959.jpg 060000.jpg 120000.jpg 180000.jpg 180001.jpg].each do |filename|
      FileUtils.touch(input_directory.join(filename))
    end

    service = StreamCompilerService.new(@stream, @date)

    assert_equal 3, service.send(:image_count)
  ensure
    FileUtils.rm_rf(Rails.root.join("storage", "streams", @stream.id.to_s))
  end
end
