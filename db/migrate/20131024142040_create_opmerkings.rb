class CreateOpmerkings < ActiveRecord::Migration
  def change
    create_table :opmerkings do |t|
      t.string :name

      t.timestamps
    end
  end
end
