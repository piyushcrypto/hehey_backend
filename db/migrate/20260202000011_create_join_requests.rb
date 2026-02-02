# frozen_string_literal: true

class CreateJoinRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :join_requests do |t|
      t.references :trip, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :travel_type, null: false
      t.integer :group_size, default: 1, null: false
      t.string :starting_location, null: false
      t.string :status, default: "pending", null: false

      t.timestamps
    end

    add_index :join_requests, :status
    add_index :join_requests, :travel_type
    add_index :join_requests, [:trip_id, :user_id], unique: true
  end
end
