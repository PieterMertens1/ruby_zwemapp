class CreateNiveaus < ActiveRecord::Migration
  def change
    create_table :niveaus do |t|
      t.string :name
      t.string :kleurcode
      t.integer :position
      t.string :karakter

      t.timestamps
    end
  end
end
