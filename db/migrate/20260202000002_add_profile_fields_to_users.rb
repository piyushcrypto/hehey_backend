# frozen_string_literal: true

class AddProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :first_name, :string, null: false, default: ""
    add_column :users, :last_name, :string, null: false, default: ""
    add_column :users, :phone, :string
    add_column :users, :country_code, :string, default: "+91"

    add_index :users, :phone, unique: true, where: "phone IS NOT NULL AND phone != ''"
  end
end
