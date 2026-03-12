require "test_helper"

class ClientTest < ActiveSupport::TestCase
  test "normalizes multiple notification emails" do
    client = Client.create!(name: "Client", email: "  First@Example.com , second@example.com ")

    assert_equal "first@example.com, second@example.com", client.email
    assert_equal [ "first@example.com", "second@example.com" ], client.notification_emails
  end

  test "rejects invalid emails in notification list" do
    client = Client.new(name: "Client", email: "valid@example.com, invalid-email")

    assert_not client.valid?
    assert_includes client.errors[:email], "contém endereço(s) inválido(s): invalid-email"
  end
end
