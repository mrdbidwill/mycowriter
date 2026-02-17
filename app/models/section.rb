class Section < ApplicationRecord
  ALLOWED_CONTENT_TYPES = %w[image/jpeg image/jpg image/png image/tiff image/gif text/plain application/pdf].freeze

  belongs_to :article
  has_many :paragraphs, -> { order(position: :asc) }, dependent: :destroy

  has_rich_text :title

  # Acts as list for reordering sections within an article
  acts_as_list scope: :article

  validates :title, presence: true, profanity: true
  validate :validate_attachment_content_types

  accepts_nested_attributes_for :paragraphs, allow_destroy: true

  private

  def validate_attachment_content_types
    return unless title.body.present?

    title.body.attachables.select { |a| a.is_a?(ActiveStorage::Blob) }.each do |attachment|
      unless ALLOWED_CONTENT_TYPES.include?(attachment.content_type)
        errors.add(:title, "contains unsupported file type: #{attachment.filename}. Allowed types: JPG, PNG, TIF, GIF, TXT, PDF")
      end
    end
  end
end
