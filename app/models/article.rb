class Article < ApplicationRecord
  ALLOWED_CONTENT_TYPES = %w[image/jpeg image/jpg image/png image/tiff image/gif text/plain application/pdf].freeze

  belongs_to :user, optional: true  # Made optional temporarily for existing records
  has_many :sections, -> { order(position: :asc) }, dependent: :destroy

  has_rich_text :description

  validates :title, presence: true, profanity: true
  validates :description, profanity: true, allow_blank: true
  validates :body, profanity: true, allow_blank: true
  validate :validate_attachment_content_types

  accepts_nested_attributes_for :sections, allow_destroy: true

  private

  def validate_attachment_content_types
    return unless description.body.present?

    description.body.attachables.select { |a| a.is_a?(ActiveStorage::Blob) }.each do |attachment|
      unless ALLOWED_CONTENT_TYPES.include?(attachment.content_type)
        errors.add(:description, "contains unsupported file type: #{attachment.filename}. Allowed types: JPG, PNG, TIF, GIF, TXT, PDF")
      end
    end
  end
end
