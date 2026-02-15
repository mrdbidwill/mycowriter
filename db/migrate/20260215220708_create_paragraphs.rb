class CreateParagraphs < ActiveRecord::Migration[8.0]
  def change
    create_table :paragraphs do |t|
      t.references :section, null: false, foreign_key: true
      t.text :content
      t.integer :position

      t.timestamps
    end
  end
end
