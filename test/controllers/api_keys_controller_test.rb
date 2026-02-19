require "test_helper"

class ApiKeysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    get api_keys_url
    assert_response :success
  end

  test "should create api_key" do
    assert_difference("ApiKey.count", 1) do
      post api_keys_url, params: { api_key: { name: "Test API Key" } }
    end
    assert_redirected_to api_keys_path
  end

  test "should destroy api_key" do
    api_key = api_keys(:one)
    delete api_key_url(api_key)
    assert_redirected_to api_keys_path
    api_key.reload
    assert_not api_key.active
  end
end
