# frozen_string_literal: true

class CreateTrips < ActiveRecord::Migration[8.1]
  def change
    create_table :trips do |t|
      # Required fields
      t.string :title, null: false
      t.string :destination, null: false
      t.text :description, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.datetime :expires_at, null: false
      t.string :image_url
      t.integer :max_people, null: false, default: 1
      t.integer :current_people, null: false, default: 1

      # Boolean fields
      t.boolean :sponsored, null: false, default: false
      t.boolean :has_car, null: false, default: false
      t.boolean :open_for_joining, null: false, default: true

      # Associations
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :trips, :destination
    add_index :trips, :sponsored
    add_index :trips, :expires_at
    add_index :trips, :created_at
  end
end
