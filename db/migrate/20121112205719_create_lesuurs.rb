class CreateLesuurs < ActiveRecord::Migration
  def change
    create_table :lesuurs do |t|
      t.string :name
      t.integer :dag_id

      t.timestamps
    end
  end
end
