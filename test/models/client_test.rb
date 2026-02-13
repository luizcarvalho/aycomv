require "test_helper"

class ClientTest < ActiveSupport::TestCase
  test "should not save client with duplicate email" do
    unique_email = "unique_#{Time.now.to_i}@example.com"
    Client.create!(name: "First Client", email: unique_email)

    duplicate_client = Client.new(name: "Second Client", email: unique_email)
    assert_not duplicate_client.save, "Saved the client with a duplicate email"
    assert_includes duplicate_client.errors[:email], "já está em uso"
  end
end
