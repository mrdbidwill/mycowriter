require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    super
    Rails.configuration.x.adsense.enabled = true
    Rails.configuration.x.adsense.client_id = "ca-pub-123"
    Rails.configuration.x.adsense.slots.inline = "111"
    Rails.configuration.x.adsense.slots.footer = "222"
  end

  def with_adsense_authenticated(value)
    original = ApplicationController.instance_method(:adsense_authenticated?)
    ApplicationController.define_method(:adsense_authenticated?) { value }
    ApplicationController.send(:private, :adsense_authenticated?)
    yield
  ensure
    ApplicationController.define_method(:adsense_authenticated?, original)
    ApplicationController.send(:private, :adsense_authenticated?)
  end

  test "demo page loads successfully" do
    get demo_url
    assert_response :success
  end

  test "demo page includes adsense when anonymous" do
    get demo_url
    assert_response :success
    assert_includes @response.body, "adsbygoogle"
    assert_includes @response.body, "pagead/js/adsbygoogle.js"
  end

  test "demo page includes auto ads bootstrap when anonymous" do
    get demo_url
    assert_response :success
    assert_includes @response.body, "pagead/js/adsbygoogle.js"
    assert_includes @response.body, "enable_page_level_ads: true"
  end

  test "demo page excludes adsense when signed in" do
    with_adsense_authenticated(true) do
      get demo_url
      assert_response :success
      assert_not_includes @response.body, "pagead/js/adsbygoogle.js"
      assert_not_includes @response.body, "adsbygoogle"
    end
  end

  test "demo page excludes adsense when opt-out cookie present" do
    get demo_url, headers: { "Cookie" => "adsense_opt_out=true" }
    assert_response :success
    assert_not_includes @response.body, "pagead/js/adsbygoogle.js"
    assert_not_includes @response.body, "adsbygoogle"
  end

  test "gem docs page loads successfully" do
    get docs_url
    assert_response :success
  end

  test "privacy page loads successfully" do
    get privacy_url
    assert_response :success
    assert_select "h1", text: /Privacy Policy/i
  end

  test "root redirects to demo" do
    get root_url
    assert_response :success
  end
end
