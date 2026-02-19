module Api
  module V1
    class GlossaryController < BaseController
      # GET /api/v1/glossary/definition?term=basidiospore
      # Public endpoint for retrieving glossary definitions
      #
      # Parameters:
      #   term (string, required): The term to look up
      #
      # Returns:
      #   JSON object with term and definition
      #
      # Example:
      #   GET /api/v1/glossary/definition?term=basidiospore
      #
      # Response (success):
      #   {
      #     "term": "basidiospore",
      #     "definition": "A spore produced on a basidium..."
      #   }
      #
      # Response (not found):
      #   {
      #     "error": "Definition not found",
      #     "term": "basidiospore"
      #   }
      def definition
        term = params[:term].to_s.strip

        if term.blank?
          render json: { error: "Term parameter is required" }, status: :bad_request
          return
        end

        definition = WikipediaGlossaryService.get_definition(term)

        if definition
          render json: { term: term, definition: definition }
        else
          render json: { error: "Definition not found", term: term }, status: :not_found
        end
      end

      # GET /api/v1/glossary/terms
      # Public endpoint for retrieving all available glossary terms
      #
      # Returns:
      #   JSON object with all terms and their definitions
      #
      # Example:
      #   GET /api/v1/glossary/terms
      #
      # Response:
      #   {
      #     "basidiospore": "A spore produced on a basidium...",
      #     "hypha": "A long, branching filamentous structure..."
      #   }
      def terms
        all_terms = WikipediaGlossaryService.fetch_glossary_terms
        render json: all_terms
      end
    end
  end
end
