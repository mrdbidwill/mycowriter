class AutocompleteController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :taxa, :genera, :species ]

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

  # GET /autocomplete/genera?q=Gano
  def genera
    query = params[:q].to_s.strip
    return render json: [] if query.length < 4

    results = MbList.where("taxon_name LIKE ?", "#{sanitize_sql_like(query.capitalize)}%")
                    .where("rank_name IN ('gen.', 'Genus') OR rank_name LIKE '%gen%'")
                    .order(:taxon_name)
                    .limit(20)
                    .pluck(:taxon_name)

    render json: results.map { |name| { name: name } }
  rescue StandardError => e
    Rails.logger.error "Error fetching genera autocomplete: #{e.message}"
    render json: { error: "Internal server error" }, status: :internal_server_error
  end

  # GET /autocomplete/species?q=sessile
  def species
    query = params[:q].to_s.strip
    return render json: [] if query.length < 4

    results = MbList.where("taxon_name LIKE ?", "%#{sanitize_sql_like(query)}%")
                    .where("rank_name IN ('sp.', 'Species') OR rank_name LIKE '%sp%'")
                    .order(:taxon_name)
                    .limit(20)
                    .pluck(:taxon_name)

    render json: results.map { |name| { name: name } }
  rescue StandardError => e
    Rails.logger.error "Error fetching species autocomplete: #{e.message}"
    render json: { error: "Internal server error" }, status: :internal_server_error
  end

  private

  def sanitize_sql_like(term)
    MbList.sanitize_sql_like(term)
  end
end
