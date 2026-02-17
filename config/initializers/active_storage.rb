# ActiveStorage configuration
Rails.application.config.after_initialize do
  # Set file size limits
  # Per-file limit: 2MB for images
  ActiveStorage::Blob.class_eval do
    before_create :validate_file_size

    private

    def validate_file_size
      if byte_size > 2.megabytes
        errors.add(:base, "File size must be less than 2MB")
        throw :abort
      end
    end
  end
end

# Configure allowed content types for Direct Uploads
Rails.application.config.active_storage.content_types_allowed_inline = %w[
  image/jpeg
  image/jpg
  image/png
  image/tiff
  image/gif
  text/plain
  application/pdf
]

# Configure content types to serve as attachments (download)
Rails.application.config.active_storage.content_types_to_serve_as_binary = %w[
  text/plain
  application/pdf
]
