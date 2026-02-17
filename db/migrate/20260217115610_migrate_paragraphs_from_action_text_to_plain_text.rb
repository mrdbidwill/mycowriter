class MigrateParagraphsFromActionTextToPlainText < ActiveRecord::Migration[8.0]
  def up
    # Temporarily add has_rich_text back to access ActionText data
    Paragraph.class_eval do
      has_rich_text :content_rich_text
    end

    # Migrate existing ActionText content to plain text column
    Paragraph.find_each do |paragraph|
      # Check if ActionText record exists
      rich_text = ActionText::RichText.find_by(
        record_type: 'Paragraph',
        record_id: paragraph.id,
        name: 'content'
      )

      if rich_text&.body&.present?
        # Convert ActionText to plain text
        plain_text = rich_text.to_plain_text
        # Update the content column directly
        paragraph.update_column(:content, plain_text)
      end
    end
  end

  def down
    # Cannot reverse this migration as ActionText data would be lost
    raise ActiveRecord::IrreversibleMigration
  end
end
