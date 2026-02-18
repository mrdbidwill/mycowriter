class ProfanityFilter
  # Uses the Obscenity gem - word list is maintained externally
  # Whitelist for legitimate scientific/mycology terms that may trigger false positives

  # Common mycology/scientific terms that should be allowed despite containing
  # substrings that might trigger profanity filters
  SCIENTIFIC_WHITELIST = [
    # Genus names
    "phallus",           # Phallus impudicus (common stinkhorn)
    "phallales",         # Order containing stinkhorns
    "phallaceae",        # Family of stinkhorn fungi
    "dictyophora",       # Veiled stinkhorn genus
    "psilocybe",         # Psilocybe genus (important for mycology research)

    # Species and descriptive terms
    "impudicus",         # As in Phallus impudicus
    "rubicundus",        # Reddish-colored species
    "hadrianus",         # Species epithet
    "ravenelii",         # Species name

    # Chemical compounds and scientific terms
    "psilocybin",        # Compound found in Psilocybe mushrooms
    "psilocin",          # Related compound in Psilocybe species
    "baeocystin",        # Another related compound

    # Anatomical/technical terms
    "volva",             # Cup at base of mushroom
    "pileus",            # Cap of mushroom
    "annulus",           # Ring on stipe
    "basidiomycota",     # Major fungal phylum
    "ascomycota",        # Another major phylum
    "obsence",           # Common typo for "absence" in mycology texts
    "obscene",           # Allow in scientific context (though usually a typo)

    # Common in scientific names
    "pubescens",         # Hairy/downy
    "tinctorius",        # Used for dyeing
    "edulis",            # Edible
  ].freeze

  def self.contains_profanity?(text)
    return false if text.blank?

    # Strip HTML tags and get plain text
    clean_text = strip_html(text)

    # Check if text contains whitelisted scientific terms
    # If so, temporarily mask them before checking for profanity
    masked_text, replacements = mask_scientific_terms(clean_text)

    # Use Obscenity gem to check for profanity on masked text
    is_profane = Obscenity.profane?(masked_text)

    # Log what was flagged for debugging (in development/test only)
    if is_profane && !Rails.env.production?
      flagged_words = find_flagged_words(clean_text)
      Rails.logger.info "=" * 80
      Rails.logger.info "PROFANITY DETECTED"
      Rails.logger.info "Flagged words: #{flagged_words.inspect}"
      Rails.logger.info "Original text (first 500 chars): #{clean_text[0..500]}"
      Rails.logger.info "Masked text (first 500 chars): #{masked_text[0..500]}"
      Rails.logger.info "=" * 80
    end

    is_profane
  end

  def self.find_profanity(text)
    return [] if text.blank?

    clean_text = strip_html(text)

    if contains_profanity?(text)
      # Try to identify specific words that triggered the filter
      find_flagged_words(clean_text)
    else
      []
    end
  end

  private

  def self.strip_html(text)
    # Handle ActionText::RichText objects
    text = text.to_plain_text if text.respond_to?(:to_plain_text)
    # Strip HTML tags
    text.to_s.gsub(/<[^>]*>/, " ").gsub(/\s+/, " ").strip
  end

  def self.mask_scientific_terms(text)
    # Temporarily replace whitelisted scientific terms with placeholders
    # to prevent false positives
    replacements = {}
    masked_text = text.dup

    SCIENTIFIC_WHITELIST.each_with_index do |term, index|
      placeholder = "SCITERM#{index}"
      # Case-insensitive replacement, preserving word boundaries
      masked_text.gsub!(/\b#{Regexp.escape(term)}\b/i) do |match|
        replacements[placeholder] = match
        placeholder
      end
    end

    [ masked_text, replacements ]
  end

  def self.find_flagged_words(text)
    # Split text into words and check each one
    # This is a best-effort approach since Obscenity doesn't expose which words matched
    words = text.split(/\W+/)
    flagged = []

    words.each do |word|
      next if word.blank?
      # Skip if it's a whitelisted scientific term
      next if SCIENTIFIC_WHITELIST.any? { |term| word.match?(/\A#{term}\z/i) }

      # Check if this individual word is profane
      if Obscenity.profane?(word)
        flagged << word
        # Log each flagged word in development
        Rails.logger.info "Individual word flagged: '#{word}'" unless Rails.env.production?
      end
    end

    # If no individual words found, log that for debugging
    if flagged.empty? && !Rails.env.production?
      Rails.logger.info "No individual words identified, but full text is flagged. Text sample: #{text[0..200]}"
    end

    flagged.empty? ? [ "inappropriate content" ] : flagged.uniq
  end
end
