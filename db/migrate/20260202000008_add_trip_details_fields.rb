# frozen_string_literal: true

class AddTripDetailsFields < ActiveRecord::Migration[8.1]
  def change
    add_column :trips, :itinerary, :text
    add_column :trips, :preferred_buddy_type, :string
    add_column :trips, :budget, :string
    add_column :trips, :transport_mode, :string
    add_column :trips, :accommodation_type, :string

    add_index :trips, :preferred_buddy_type
    add_index :trips, :transport_mode
    add_index :trips, :accommodation_type
  end
end
