class CreateRapports < ActiveRecord::Migration
  def change
    create_table :rapports do |t|
      t.integer :zwemmer_id
      t.string :lesgever
      t.string :niveau
      t.string :standaard_extra
      t.string :extra
      t.boolean :klaar
      
      t.timestamps
    end
  end
end
