require "test_helper"

class VideosControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @video_one = videos(:one)
    @video_two = videos(:two)
    @video_three = videos(:three)
  end

  test "should get index" do
    get videos_url
    assert_response :success
  end

  test "should filter by date" do
    get videos_url, params: { date: "2023-10-01" }
    assert_response :success

    # Needs to match videos from 2023-10-01
    assert_match @video_one.stream.name, response.body
    assert_match @video_three.stream.name, response.body

    # Should not match videos from 2023-10-02
    # Ensure @video_two is not displayed. ID selector is safer.
    assert_select "#video_#{@video_two.id}", false
    assert_select "#video_#{@video_one.id}"
  end

  test "should sort by oldest" do
    get videos_url, params: { sort: "oldest" }
    assert_response :success

    # Verify order: One (10:00), Three (11:00), Two (Next Day 10:00)
    # Actually One and Two are same Stream One. Three is Stream Two.
    # One: 2023-10-01 10:00
    # Two: 2023-10-02 10:00
    # Three: 2023-10-01 11:00

    # Oldest -> Ascending `generated_at`
    # Expected: One, Three, Two

    # Extract IDs from response body
    matches = response.body.scan(/id="video_(\d+)"/).flatten
    assert_equal [ @video_one.id.to_s, @video_three.id.to_s, @video_two.id.to_s ], matches
  end

  test "should sort by newest (default)" do
    get videos_url
    assert_response :success

    # Newest -> Descending `generated_at`
    # Expected: Two, Three, One

    matches = response.body.scan(/id="video_(\d+)"/).flatten
    assert_equal [ @video_two.id.to_s, @video_three.id.to_s, @video_one.id.to_s ], matches
  end

  test "should sort by shortest duration" do
    get videos_url, params: { sort: "shortest" }
    assert_response :success

    # One: 60s
    # Two: 120s
    # Three: 180s
    # Expected: One, Two, Three

    matches = response.body.scan(/id="video_(\d+)"/).flatten
    assert_equal [ @video_one.id.to_s, @video_two.id.to_s, @video_three.id.to_s ], matches
  end
end
