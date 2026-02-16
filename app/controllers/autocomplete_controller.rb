class AutocompleteController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :taxa ]

  # GET /autocomplete/taxa?q=Agaricus
  def taxa
    query = params[:q].to_s.strip

    if query.blank?
      render json: []
      return
    end

    results = MbList.search_by_name(query).limit(20).pluck(:taxon_name, :rank_name, :authors)

    formatted_results = results.map do |name, rank, authors|
      {
        value: name,
        label: "#{name} (#{rank})",
        authors: authors
      }
    end

    render json: formatted_results
  rescue StandardError => e
    Rails.logger.error "Error fetching taxa autocomplete: #{e.message}"
    render json: { error: "Internal server error" }, status: :internal_server_error
  end
end
