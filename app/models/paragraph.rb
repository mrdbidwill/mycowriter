class Paragraph < ApplicationRecord
  belongs_to :section

  # Acts as list for reordering paragraphs within a section
  acts_as_list scope: :section

  validates :content, presence: true, profanity: true
end
