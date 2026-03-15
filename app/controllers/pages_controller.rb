class PagesController < ApplicationController
  def contact
  end

  def terms_of_service
  end

  def gem_docs
  end

  def demo
  end

  def privacy
    @adsense_opted_out = adsense_opted_out?
  end

  def opt_out
    cookies[:adsense_opt_out] = {
      value: "true",
      expires: 1.year,
      same_site: :lax
    }
    redirect_to privacy_path
  end

  def opt_in
    cookies.delete(:adsense_opt_out)
    redirect_to privacy_path
  end
end
