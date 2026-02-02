# frozen_string_literal: true

class RemoveTitleFromTrips < ActiveRecord::Migration[8.1]
  def change
    remove_column :trips, :title, :string
  end
end
