class CreateNieuws < ActiveRecord::Migration
  def change
    create_table :nieuws do |t|
      t.string :soort
      t.string :datum
      t.text :content

      t.timestamps
    end
  end
end
