class Paragraph < ApplicationRecord
  belongs_to :section

  validates :content, presence: true
  validates :position, presence: true

  before_validation :set_position, on: :create
  before_save :sanitize_content

  private

  def set_position
    return if position.present?
    self.position = section.paragraphs.maximum(:position).to_i + 1
  end

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
