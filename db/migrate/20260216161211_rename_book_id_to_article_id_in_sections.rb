class RenameBookIdToArticleIdInSections < ActiveRecord::Migration[8.0]
  def change
    rename_column :sections, :book_id, :article_id
  end
end
