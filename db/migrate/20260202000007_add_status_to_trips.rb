# frozen_string_literal: true

class AddStatusToTrips < ActiveRecord::Migration[8.1]
  def change
    add_column :trips, :status, :string, default: "active", null: false
    add_index :trips, :status
  end
end
