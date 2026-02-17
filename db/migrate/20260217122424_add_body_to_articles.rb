class AddBodyToArticles < ActiveRecord::Migration[8.0]
  def change
    add_column :articles, :body, :text
  end
end
