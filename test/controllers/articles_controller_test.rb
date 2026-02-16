require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url
    assert_response :success
  end

  test "should get show" do
    get article_url(articles(:one))
    assert_response :success
  end

  test "should get new" do
    sign_in users(:one)
    get new_article_url
    assert_response :success
  end

  test "should get edit" do
    sign_in users(:one)
    get edit_article_url(articles(:one))
    assert_response :success
  end
end
