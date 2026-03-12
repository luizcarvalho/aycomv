require "test_helper"

class ClientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
  end

  test "should get new" do
    get new_client_url
    assert_response :success
  end

  test "should create client" do
    assert_difference("Client.count") do
      post clients_url, params: { client: { name: "New Client", email: "new@example.com" } }
    end

    assert_redirected_to clients_url
  end

  test "should show error when creating client with invalid email list" do
    invalid_email = "invalid-email"

    assert_no_difference("Client.count") do
      post clients_url, params: { client: { name: "Another Client", email: "valid@example.com, #{invalid_email}" } }
    end

    assert_response :unprocessable_entity
    assert_select "div.error_explanation"
    assert_select "li", /#{invalid_email}/
  end

  test "should show error when updating client with invalid email list" do
    client = Client.create!(name: "Client 1", email: "client1@example.com")

    patch client_url(client), params: { client: { email: "client2@example.com, invalid-email" } }

    assert_response :unprocessable_entity
    assert_select "div.error_explanation"
    assert_select "li", /invalid-email/
  end
end
