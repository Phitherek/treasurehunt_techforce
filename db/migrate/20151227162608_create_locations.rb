class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.decimal :latitude, null: false, default: 0
      t.decimal :longitude, null: false, default: 0
      t.belongs_to :user
      t.timestamps null: false
    end
  end
end
