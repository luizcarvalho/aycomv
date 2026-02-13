require "test_helper"

class ClientsControllerTest < ActionDispatch::IntegrationTest
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

  test "should show error when creating duplicate client" do
    Client.create!(name: "Existing Client", email: "existing@example.com")

    assert_no_difference("Client.count") do
      post clients_url, params: { client: { name: "Another Client", email: "existing@example.com" } }
    end

    assert_response :unprocessable_entity
    assert_select "div.error_explanation"
    assert_select "li", /já está em uso/
  end

  test "should show error when updating client with duplicate email" do
    client = Client.create!(name: "Client 1", email: "client1@example.com")
    Client.create!(name: "Client 2", email: "client2@example.com")

    patch client_url(client), params: { client: { email: "client2@example.com" } }

    assert_response :unprocessable_entity
    assert_select "div.error_explanation"
    assert_select "li", /já está em uso/
  end
end
