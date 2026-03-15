require "test_helper"

class AdsenseHelperTest < ActionView::TestCase
  def setup
    super
    Rails.configuration.x.adsense.enabled = true
    Rails.configuration.x.adsense.client_id = "ca-pub-123"
    Rails.configuration.x.adsense.slots.inline = "111"
  end

  def with_adsense_context(authenticated: false, opted_out: false)
    controller_double = Object.new
    controller_double.define_singleton_method(:adsense_authenticated?) { authenticated }
    controller_double.define_singleton_method(:adsense_opted_out?) { opted_out }
    original = method(:controller) if respond_to?(:controller)
    define_singleton_method(:controller) { controller_double }
    yield
  ensure
    if original
      define_singleton_method(:controller, original)
    else
      singleton_class.remove_method(:controller) if singleton_class.method_defined?(:controller)
    end
  end

  test "adsense disabled without client id" do
    Rails.configuration.x.adsense.client_id = nil
    assert_not adsense_enabled?
  end

  test "adsense allowed when enabled and anonymous" do
    with_adsense_context(authenticated: false, opted_out: false) do
      assert adsense_allowed_for_request?
    end
  end

  test "adsense blocked when authenticated" do
    with_adsense_context(authenticated: true, opted_out: false) do
      assert_not adsense_allowed_for_request?
    end
  end

  test "adsense blocked when opted out" do
    with_adsense_context(authenticated: false, opted_out: true) do
      assert_not adsense_allowed_for_request?
    end
  end

  test "adsense script tag renders when allowed" do
    with_adsense_context(authenticated: false, opted_out: false) do
      html = adsense_script_tag
      assert_includes html, "pagead/js/adsbygoogle.js"
    end
  end

  test "adsense slot tag does not render without slot" do
    with_adsense_context(authenticated: false, opted_out: false) do
      html = adsense_slot_tag(slot: nil)
      assert_nil html
    end
  end
end
