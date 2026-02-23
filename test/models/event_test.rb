require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "should not save event without modulo" do
    event = Event.new(rotulo: "test")
    assert_not event.save, "Saved the event without modulo"
  end

  test "should not save event without rotulo" do
    event = Event.new(modulo: "test")
    assert_not event.save, "Saved the event without rotulo"
  end

  test "Event.log creates an event" do
    assert_difference "Event.count", 1 do
      Event.log(modulo: "client", rotulo: "client_created", valor: 42, object_id: 42, metadata: { name: "Test" })
    end

    event = Event.last
    assert_equal "client", event.modulo
    assert_equal "client_created", event.rotulo
    assert_equal "42", event.valor
    assert_equal 42, event.object_id
    assert_equal({ "name" => "Test" }, event.metadata)
  end

  test "Event.log does not raise on failure" do
    assert_nothing_raised do
      Event.log(modulo: nil, rotulo: nil)
    end
  end

  test "by_modulo scope filters by modulo" do
    events = Event.by_modulo("stream")
    assert events.all? { |e| e.modulo == "stream" }
  end

  test "by_object scope filters by object_id" do
    events = Event.by_object(1)
    assert events.all? { |e| e.object_id == 1 }
  end
end
