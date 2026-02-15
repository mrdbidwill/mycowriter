class GlossaryController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:definition]

  # GET /glossary/definition?term=basidiospore
  def definition
    term = params[:term]

    if term.blank?
      respond_to do |format|
        format.json { render json: { error: "Term parameter is required" }, status: :bad_request }
      end
      return
    end

    definition = WikipediaGlossaryService.get_definition(term)

    respond_to do |format|
      if definition
        format.json { render json: { term: term, definition: definition } }
      else
        format.json { render json: { error: "Definition not found", term: term }, status: :not_found }
      end
    end
  rescue StandardError => e
    Rails.logger.error "Error fetching glossary definition: #{e.message}"
    respond_to do |format|
      format.json { render json: { error: "Internal server error" }, status: :internal_server_error }
    end
  end

  # GET /glossary - Optional: browse all terms
  def index
    @terms = WikipediaGlossaryService.fetch_glossary_terms
    @terms = @terms.sort_by { |k, _v| k.downcase }
  end
end
