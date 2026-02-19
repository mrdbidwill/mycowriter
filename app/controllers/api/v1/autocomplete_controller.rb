module Api
  module V1
    class AutocompleteController < BaseController
      # GET /api/v1/autocomplete/taxa?q=Agaricus
      # Public endpoint for autocompleting fungal taxa names
      #
      # Parameters:
      #   q (string, required): Search query (minimum 1 character)
      #   limit (integer, optional): Maximum number of results (default: 20, max: 100)
      #
      # Returns:
      #   JSON array of matching taxa with name, rank, and authors
      #
      # Example:
      #   GET /api/v1/autocomplete/taxa?q=Agaricus&limit=10
      #
      # Response:
      #   [
      #     {
      #       "value": "Agaricus",
      #       "label": "Agaricus (Genus)",
      #       "authors": "L."
      #     }
      #   ]
      def taxa
        query = params[:q].to_s.strip
        limit = [params[:limit].to_i, 100].min
        limit = 20 if limit <= 0

        if query.blank?
          render json: { error: "Query parameter 'q' is required" }, status: :bad_request
          return
        end

        results = MbList.search_by_name(query).limit(limit).pluck(:taxon_name, :rank_name, :authors)

        formatted_results = results.map do |name, rank, authors|
          {
            value: name,
            label: "#{name} (#{rank})",
            authors: authors
          }
        end

        render json: formatted_results
      end
    end
  end
end
