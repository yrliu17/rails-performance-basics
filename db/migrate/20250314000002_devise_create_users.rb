# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      enable_extension("citext")
      ## Database authenticatable
      t.citext :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      t.citext :username, null: false
      t.string :display_name
      t.string :avatar_image
      t.string :profile_banner
      t.string :bio
      t.string :website
      t.boolean :private, default: true
      t.integer :likes_count, default: 0
      t.integer :comments_count, default: 0
      t.integer :photos_count, default: 0

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :username,             unique: true
  end
end
