class CreateFouts < ActiveRecord::Migration
  def change
    create_table :fouts do |t|
      t.string :name
      t.integer :proef_id
      t.integer :position
      
      t.timestamps
    end
  end
end
