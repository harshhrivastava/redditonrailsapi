class CreatingCommentModel < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.string :author, null: false
      t.text :comment, null: false
      t.integer :replies, null: false, default: 0
      t.references :commentable, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true, null: false
    
      t.timestamps
    end
    
  end
end
