class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.string :name
      t.text :niveaus
      t.text :totals
      t.text :details

      t.timestamps
    end
  end
end
