class CreateProefs < ActiveRecord::Migration
  def change
    create_table :proefs do |t|
      t.integer :niveau_id
      t.string :scoretype
      t.boolean :belangrijk
      t.string :content
      t.integer :position
      t.boolean :nietdilbeeks

      t.timestamps
    end
  end
end
