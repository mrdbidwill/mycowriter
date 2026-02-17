class MigrateArticleDescriptionFromActionTextToPlainText < ActiveRecord::Migration[8.0]
  def up
    # Migrate existing ActionText description to plain text column
    Article.find_each do |article|
      # Check if ActionText record exists
      rich_text = ActionText::RichText.find_by(
        record_type: 'Article',
        record_id: article.id,
        name: 'description'
      )

      if rich_text&.body&.present?
        # Convert ActionText to plain text
        plain_text = rich_text.to_plain_text
        # Update the description column directly
        article.update_column(:description, plain_text)
      end
    end
  end

  def down
    # Cannot reverse this migration as ActionText data would be lost
    raise ActiveRecord::IrreversibleMigration
  end
end
