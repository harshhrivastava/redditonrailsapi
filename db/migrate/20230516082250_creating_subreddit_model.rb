class CreatingSubredditModel < ActiveRecord::Migration[7.0]
  def change
    create_table :subreddits do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.integer :replies, default: 0, null: false
      t.string :author, null: false
      t.references :user, null: false, foreign_key: true
    
      t.timestamps
    end
    
  end
end
