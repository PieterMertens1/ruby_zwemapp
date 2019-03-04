class CreateTijds < ActiveRecord::Migration
  def change
    create_table :tijds do |t|
      t.integer :aantal

      t.timestamps
    end
  end
end
