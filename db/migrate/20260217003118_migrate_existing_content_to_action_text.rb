class MigrateExistingContentToActionText < ActiveRecord::Migration[8.0]
  def up
    # Migrate Article descriptions
    Article.find_each do |article|
      if article.description.present? && !article.description.is_a?(ActionText::RichText)
        article.update_column(:description, article.description)
      end
    end

    # Migrate Section titles
    Section.find_each do |section|
      if section.title.present? && !section.title.is_a?(ActionText::RichText)
        section.update_column(:title, section.title)
      end
    end

    # Migrate Paragraph content
    Paragraph.find_each do |paragraph|
      if paragraph.content.present? && !paragraph.content.is_a?(ActionText::RichText)
        paragraph.update_column(:content, paragraph.content)
      end
    end
  end

  def down
    # No rollback needed - data remains in Action Text tables
  end
end
