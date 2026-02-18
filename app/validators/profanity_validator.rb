class ProfanityValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    # Handle both plain text and ActionText::RichText
    text_content = value.respond_to?(:to_plain_text) ? value.to_plain_text : value.to_s

    if ProfanityFilter.contains_profanity?(text_content)
      found_words = ProfanityFilter.find_profanity(text_content)
      record.errors.add(attribute, "contains inappropriate language and cannot be saved. This is a family-friendly mycology project for ALL AGES — profanity is not allowed. Please remove all inappropriate language and try again.")
    end
  end
end
