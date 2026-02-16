class Paragraph < ApplicationRecord
  belongs_to :section

  # Acts as list for reordering paragraphs within a section
  acts_as_list scope: :section

  validates :content, presence: true

  before_save :sanitize_content

  private

  def sanitize_content
    # Allow specific HTML tags for formatting
    allowed_tags = %w[p b i u em strong code pre sup sub ol ul li blockquote hr br]
    allowed_attributes = []

    self.content = ActionController::Base.helpers.sanitize(
      content,
      tags: allowed_tags,
      attributes: allowed_attributes
    )
  end
end
