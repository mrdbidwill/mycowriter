class Paragraph < ApplicationRecord
  ALLOWED_CONTENT_TYPES = %w[image/jpeg image/jpg image/png image/tiff image/gif text/plain application/pdf].freeze

  belongs_to :section

  has_rich_text :content

  # Acts as list for reordering paragraphs within a section
  acts_as_list scope: :section

  validates :content, presence: true, profanity: true
  validate :validate_attachment_content_types

  private

  def validate_attachment_content_types
    return unless content.body.present?

    content.body.attachables.select { |a| a.is_a?(ActiveStorage::Blob) }.each do |attachment|
      unless ALLOWED_CONTENT_TYPES.include?(attachment.content_type)
        errors.add(:content, "contains unsupported file type: #{attachment.filename}. Allowed types: JPG, PNG, TIF, GIF, TXT, PDF")
      end
    end
  end
end
