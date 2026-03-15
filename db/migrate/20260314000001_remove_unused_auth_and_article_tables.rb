class RemoveUnusedAuthAndArticleTables < ActiveRecord::Migration[8.0]
  def up
    drop_table :api_keys, if_exists: true
    drop_table :paragraphs, if_exists: true
    drop_table :sections, if_exists: true
    drop_table :articles, if_exists: true
    drop_table :users, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Dropped demo-only auth/article tables."
  end
end
