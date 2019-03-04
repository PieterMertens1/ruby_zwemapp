class CreateGroeps < ActiveRecord::Migration
  def change
    create_table :groeps do |t|
      t.integer :lesgever_id
      t.integer :lesuur_id
      t.integer :niveau_id
      t.boolean :done_vlag
      
      t.timestamps
    end
  end
end
