class CreateKlas < ActiveRecord::Migration
  def change
    create_table :klas do |t|
      t.string :name
      t.integer :school_id
      t.integer :lesuur_id
      t.boolean :tweeweek
      t.boolean :nietdilbeeks
      t.integer :week, default: 0

      t.timestamps
    end
  end
end
