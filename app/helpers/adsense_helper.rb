module AdsenseHelper
  def adsense_enabled?
    Rails.configuration.x.adsense.enabled &&
      Rails.configuration.x.adsense.client_id.present?
  end

  def adsense_allowed_for_request?
    adsense_enabled? && !adsense_authenticated_request? && !adsense_opted_out_request?
  end

  def adsense_script_tag
    return unless adsense_allowed_for_request?

    tag.script(
      async: true,
      src: "https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=#{Rails.configuration.x.adsense.client_id}",
      crossorigin: "anonymous"
    )
  end

  def adsense_auto_ads_tag
    return unless adsense_allowed_for_request?

    javascript_tag(
      "(adsbygoogle = window.adsbygoogle || []).push({ google_ad_client: '#{Rails.configuration.x.adsense.client_id}', enable_page_level_ads: true });"
    )
  end

  def adsense_slot_tag(slot:, format: "auto")
    return unless adsense_allowed_for_request?
    return if slot.blank?

    tag.ins(
      class: "adsbygoogle",
      style: "display:block",
      "data-ad-client": Rails.configuration.x.adsense.client_id,
      "data-ad-slot": slot,
      "data-ad-format": format,
      "data-full-width-responsive": "true"
    )
  end

  private

  def adsense_authenticated_request?
    if respond_to?(:controller) && controller&.respond_to?(:adsense_authenticated?, true)
      return controller.send(:adsense_authenticated?)
    end

    false
  end

  def adsense_opted_out_request?
    if respond_to?(:controller) && controller&.respond_to?(:adsense_opted_out?, true)
      return controller.send(:adsense_opted_out?)
    end

    false
  end
end
