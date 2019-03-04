class CreateFoutwijzings < ActiveRecord::Migration
  def change
    create_table :foutwijzings do |t|
      t.integer :resultaat_id
      t.integer :fout_id

      t.timestamps
    end
  end
end
