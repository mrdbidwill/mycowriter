class ChangeArticleBodyToMediumtext < ActiveRecord::Migration[8.0]
  def change
    change_column :articles, :body, :text, limit: 16777215
  end
end
