class RenameBookToArticle < ActiveRecord::Migration[8.0]
  def change
    rename_table :books, :articles
  end
end
