class AddEmailConfirmationToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :email_confirmation_token, :string, null: false
    add_column :users, :email_confirmation_status, :boolean, default: false
  end
end
