class CreateResultaats < ActiveRecord::Migration
  def change
    create_table :resultaats do |t|
      t.string :name
      t.integer :rapport_id
      t.string :score

      t.timestamps
    end
  end
end
