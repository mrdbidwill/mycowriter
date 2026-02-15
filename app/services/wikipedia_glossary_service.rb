require "net/http"
require "json"

class WikipediaGlossaryService
  GLOSSARY_PAGE = "Glossary_of_mycology"
  API_ENDPOINT = "https://en.wikipedia.org/w/api.php"
  CACHE_EXPIRY = 24.hours

  class << self
    # Fetch all glossary terms from Wikipedia
    def fetch_glossary_terms
      Rails.cache.fetch("wikipedia_glossary_terms", expires_in: CACHE_EXPIRY) do
        parse_glossary_page
      end
    end

    # Get definition for a specific term
    def get_definition(term)
      normalized_term = normalize_term(term)
      terms = fetch_glossary_terms

      # Try exact match first
      definition = terms[normalized_term]
      return definition if definition

      # Try case-insensitive match
      terms.each do |key, value|
        return value if key.downcase == normalized_term.downcase
      end

      # Try removing plural 's' if no match found
      if normalized_term.end_with?("s") && !normalized_term.end_with?("ss")
        singular = normalized_term.chomp("s")
        definition = terms[singular]
        return definition if definition

        # Try case-insensitive singular match
        terms.each do |key, value|
          return value if key.downcase == singular.downcase
        end
      end

      # Try removing 'es' ending (e.g., "hyphes" -> "hypha")
      if normalized_term.end_with?("es")
        singular = normalized_term.chomp("es")
        definition = terms[singular]
        return definition if definition

        terms.each do |key, value|
          return value if key.downcase == singular.downcase
        end
      end

      nil
    end

    # Check if a term exists in the glossary
    def term_exists?(term)
      normalized_term = normalize_term(term)
      terms = fetch_glossary_terms

      terms.key?(normalized_term) || terms.keys.any? { |k| k.downcase == normalized_term.downcase }
    end

    private

    def normalize_term(term)
      # Remove hyphens, normalize spacing
      term.to_s.strip.gsub(/[‐‑‒–—―]/, "-")
    end

    def parse_glossary_page
      content = fetch_page_content
      return {} unless content

      extract_terms_from_html(content)
    end

    def fetch_page_content
      uri = URI(API_ENDPOINT)
      params = {
        action: "parse",
        page: GLOSSARY_PAGE,
        format: "json",
        prop: "text",
        disableeditsection: 1,
        disabletoc: 1
      }
      uri.query = URI.encode_www_form(params)

      request = Net::HTTP::Get.new(uri)
      request["User-Agent"] = "MycoWriter/1.0 (mycowriter.com; Educational/Research)"

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 10) do |http|
        http.request(request)
      end

      if response.code == "200"
        data = JSON.parse(response.body)
        data.dig("parse", "text", "*")
      else
        Rails.logger.error "Wikipedia API error: #{response.code} - #{response.body}"
        nil
      end
    rescue StandardError => e
      Rails.logger.error "Error fetching Wikipedia glossary: #{e.message}"
      nil
    end

    def extract_terms_from_html(html)
      terms = {}

      # Wikipedia glossary format: <dt>term</dt><dd>definition</dd>
      html.scan(/<dt[^>]*>(.*?)<\/dt>\s*<dd[^>]*>(.*?)<\/dd>/m) do |term_html, def_html|
        term = strip_html_tags(term_html).strip
        definition = clean_definition(def_html)

        terms[term] = definition unless term.empty? || definition.empty?
      end

      terms
    end

    def strip_html_tags(text)
      text.gsub(/<\/?[^>]*>/, "")
          .gsub(/\s+/, " ")
          .strip
    end

    def clean_definition(html)
      # Remove edit links, references, etc.
      cleaned = html.gsub(/<span class="mw-editsection".*?<\/span>/m, "")
                   .gsub(/<sup[^>]*>.*?<\/sup>/m, "")
                   .gsub(/\[edit\]/i, "")

      strip_html_tags(cleaned).strip
    end
  end
end
