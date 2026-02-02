# frozen_string_literal: true

class AddSplittingTypeToTrips < ActiveRecord::Migration[8.1]
  def change
    add_column :trips, :splitting_type, :string, default: "equal", null: false
    add_index :trips, :splitting_type
  end
end
