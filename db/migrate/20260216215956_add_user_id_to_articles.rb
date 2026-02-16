class AddUserIdToArticles < ActiveRecord::Migration[8.0]
  def change
    add_reference :articles, :user, null: true, foreign_key: true

    # Update existing articles to belong to the first user if any exist
    reversible do |dir|
      dir.up do
        if User.exists? && Article.exists?
          first_user = User.first
          Article.where(user_id: nil).update_all(user_id: first_user.id)
        end
      end
    end

    # Now make the column non-nullable
    change_column_null :articles, :user_id, false
  end
end
