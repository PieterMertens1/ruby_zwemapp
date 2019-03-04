class CreateZwemmers < ActiveRecord::Migration
  def change
    create_table :zwemmers do |t|
      t.string :name
      t.string :email
      t.string :extra
      t.integer :kla_id
      t.integer :groep_id
      t.boolean :overvlag
      t.boolean :netovervlag
      t.integer :groepvlag, :default => 0
      t.boolean :importvlag

      t.timestamps
    end
  end
end
