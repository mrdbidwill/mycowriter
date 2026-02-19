require "test_helper"

class ApiDocsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_docs_path
    assert_response :success
  end
end
