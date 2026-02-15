module GlossaryHelper
  # Mark glossary terms in text with special HTML markup
  # Options:
  #   first_only: true - only mark first occurrence of each term (default: true)
  def mark_glossary_terms(text, options = {})
    return text if text.blank?

    first_only = options.fetch(:first_only, true)
    marked_terms = Set.new

    terms = WikipediaGlossaryService.fetch_glossary_terms
    return text if terms.empty?

    # Sort terms by length (longest first) to avoid partial matches
    sorted_terms = terms.keys.sort_by { |t| -t.length }

    result = text.dup

    sorted_terms.each do |term|
      # Skip if we've already marked this term and first_only is true
      next if first_only && marked_terms.include?(term.downcase)

      # Create regex pattern for word boundaries
      # Match the term with optional 's' for plural
      pattern = /\b(#{Regexp.escape(term)}s?)\b/i

      # Replace first or all occurrences
      if first_only
        result = result.sub(pattern) do |match|
          marked_terms.add(term.downcase)
          glossary_term_tag(match)
        end
      else
        result = result.gsub(pattern) do |match|
          glossary_term_tag(match)
        end
      end
    end

    result.html_safe
  end

  private

  def glossary_term_tag(term)
    # Normalize to singular form for lookup
    normalized = normalize_term_for_lookup(term)
    %(<span class="glossary-term" data-term="#{CGI.escapeHTML(normalized)}" tabindex="0">#{CGI.escapeHTML(term)}</span>)
  end

  def normalize_term_for_lookup(term)
    normalized = term.downcase.strip

    # Remove common plural endings
    if normalized.end_with?("s") && !normalized.end_with?("ss")
      # Try removing 's' for simple plurals
      singular = normalized.chomp("s")

      # Check if singular form exists in glossary
      terms = WikipediaGlossaryService.fetch_glossary_terms
      return singular if terms.keys.any? { |k| k.downcase == singular }
    end

    normalized
  end
end
