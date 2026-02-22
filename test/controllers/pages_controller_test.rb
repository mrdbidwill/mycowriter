require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "demo page loads successfully" do
    get demo_url
    assert_response :success
  end

  test "gem docs page loads successfully" do
    get docs_url
    assert_response :success
  end

  test "root redirects to demo" do
    get root_url
    assert_response :success
  end
end
