class Article < ApplicationRecord
  belongs_to :user, optional: true  # Made optional temporarily for existing records
  has_many :sections, -> { order(position: :asc) }, dependent: :destroy
  has_rich_text :body

  validates :title, presence: true

  accepts_nested_attributes_for :sections, allow_destroy: true

  before_save :clean_body_content

  private

  def clean_body_content
    return unless body.present?

    # Get the HTML content from ActionText
    html = body.to_s

    # Clean excessive line breaks
    # Remove hyphenated line breaks: "as-<br>comycetes" -> "ascomycetes"
    html = html.gsub(/(\w)-\s*<br\s*\/?>\s*(\w)/i, '\1\2')

    # Replace single <br> tags with spaces to join wrapped text
    # But preserve multiple <br> tags (paragraph breaks)
    html = html.gsub(/([^>])<br\s*\/?>\s*([^<])/i, '\1 \2')

    # Collapse excessive <br> tags (3+ in a row to 2)
    html = html.gsub(/(<br\s*\/?>\s*){3,}/i, '<br><br>')

    # Update the body with cleaned content
    self.body = html
  end
end
