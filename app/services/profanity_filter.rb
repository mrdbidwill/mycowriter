class ProfanityFilter
  # Uses the Obscenity gem - word list is maintained externally
  # No profanity words stored in this codebase

  def self.contains_profanity?(text)
    return false if text.blank?

    # Strip HTML tags and get plain text
    clean_text = strip_html(text)

    # Use Obscenity gem to check for profanity
    Obscenity.profane?(clean_text)
  end

  def self.find_profanity(text)
    return [] if text.blank?

    clean_text = strip_html(text)

    # Obscenity doesn't provide a list of found words, but we can still use it
    Obscenity.profane?(clean_text) ? [ "inappropriate content" ] : []
  end

  private

  def self.strip_html(text)
    # Handle ActionText::RichText objects
    text = text.to_plain_text if text.respond_to?(:to_plain_text)
    # Strip HTML tags
    text.to_s.gsub(/<[^>]*>/, " ").gsub(/\s+/, " ").strip
  end
end
