# frozen_string_literal: true

class RemoveExpiresAtFromTrips < ActiveRecord::Migration[8.1]
  def change
    remove_index :trips, :expires_at
    remove_column :trips, :expires_at, :datetime
  end
end
