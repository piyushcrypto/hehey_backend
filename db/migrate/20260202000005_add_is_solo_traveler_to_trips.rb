# frozen_string_literal: true

class AddIsSoloTravelerToTrips < ActiveRecord::Migration[8.1]
  def change
    add_column :trips, :is_solo_traveler, :boolean, null: false, default: false
    add_index :trips, :is_solo_traveler
  end
end
