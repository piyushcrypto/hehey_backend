# frozen_string_literal: true

class AddProfileDetailsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :gender, :string
    add_column :users, :city, :string
    add_column :users, :work_profile, :string

    add_index :users, :gender
    add_index :users, :city
  end
end
